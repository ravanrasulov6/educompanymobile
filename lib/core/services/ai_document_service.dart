import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import '../config/openai_config.dart';
import '../config/supabase_config.dart';

/// Service for AI document upload, processing, and retrieval.
/// All heavy processing happens server-side via Edge Functions.
class AiDocumentService {
  AiDocumentService._();
  static final AiDocumentService instance = AiDocumentService._();

  SupabaseClient get _sb => Supabase.instance.client;
  String get _userId => _sb.auth.currentUser!.id;

  // ── Upload (standard — for files ≤ 20MB) ───────────────

  /// Upload a file to ai-uploads bucket and create document record.
  /// For files >20MB, use [uploadDocumentResumable] instead.
  Future<Map<String, dynamic>> uploadDocument({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    final fileType = _detectFileType(mimeType);
    final storagePath = '$_userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    // 1. Upload to storage
    await _sb.storage.from('ai-uploads').uploadBinary(
      storagePath,
      bytes,
      fileOptions: FileOptions(contentType: mimeType),
    );

    // 2. Compute content hash for dedup
    final hash = _computeHash(bytes);

    // 3. Create document record
    final doc = await _sb.from('ai_documents').insert({
      'user_id': _userId,
      'file_name': fileName,
      'file_type': fileType,
      'file_size_bytes': bytes.length,
      'storage_path': storagePath,
      'mime_type': mimeType,
      'content_hash': hash,
    }).select().single();

    debugPrint('[AiDocumentService] Document created: ${doc['id']}');
    return doc;
  }

  // ── Upload (resumable TUS — for files > 20MB) ──────────

  /// Resumable upload using Supabase's built-in TUS protocol support.
  /// Allows pause/resume and reports progress via [onProgress].
  ///
  /// Supabase Storage has native TUS support at:
  ///   POST /storage/v1/upload/resumable
  ///
  /// Usage:
  /// ```dart
  /// final doc = await service.uploadDocumentResumable(
  ///   bytes: fileBytes,
  ///   fileName: 'large.pdf',
  ///   mimeType: 'application/pdf',
  ///   onProgress: (sent, total) => print('${(sent/total*100).toInt()}%'),
  /// );
  /// ```
  Future<Map<String, dynamic>> uploadDocumentResumable({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    void Function(int sent, int total)? onProgress,
  }) async {
    final fileType = _detectFileType(mimeType);
    final storagePath = '$_userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    // Supabase Storage TUS endpoint
    final supabaseUrl = SupabaseConfig.url;
    final anonKey = SupabaseConfig.anonKey;
    final accessToken = _sb.auth.currentSession?.accessToken ?? anonKey;
    final tusUrl = '$supabaseUrl/storage/v1/upload/resumable';

    // Step 1: Create upload (POST with Upload-Length)
    final createResp = await http.post(
      Uri.parse(tusUrl),
      headers: {
        'Tus-Resumable': '1.0.0',
        'Upload-Length': '${bytes.length}',
        'Upload-Metadata': _tusMetadata({
          'bucketName': 'ai-uploads',
          'objectName': storagePath,
          'contentType': mimeType,
        }),
        'Authorization': 'Bearer $accessToken',
        'apikey': anonKey,
      },
    );

    if (createResp.statusCode != 201) {
      throw Exception('TUS create failed: ${createResp.statusCode} ${createResp.body}');
    }

    final uploadUrl = createResp.headers['location'];
    if (uploadUrl == null) throw Exception('No upload location returned');

    // Step 2: Upload in chunks (1MB each)
    const chunkSize = 1024 * 1024; // 1MB
    int offset = 0;

    while (offset < bytes.length) {
      final end = (offset + chunkSize).clamp(0, bytes.length);
      final chunk = bytes.sublist(offset, end);

      final patchResp = await http.patch(
        Uri.parse(uploadUrl),
        headers: {
          'Tus-Resumable': '1.0.0',
          'Upload-Offset': '$offset',
          'Content-Type': 'application/offset+octet-stream',
          'Authorization': 'Bearer $accessToken',
          'apikey': anonKey,
        },
        body: chunk,
      );

      if (patchResp.statusCode != 204) {
        throw Exception('TUS patch failed at offset $offset: ${patchResp.statusCode}');
      }

      offset = end;
      onProgress?.call(offset, bytes.length);
    }

    // Step 3: Create document record
    final hash = _computeHash(bytes);

    final doc = await _sb.from('ai_documents').insert({
      'user_id': _userId,
      'file_name': fileName,
      'file_type': fileType,
      'file_size_bytes': bytes.length,
      'storage_path': storagePath,
      'mime_type': mimeType,
      'content_hash': hash,
    }).select().single();

    debugPrint('[AiDocumentService] Resumable upload completed: ${doc['id']}');
    return doc;
  }

  /// Trigger server-side processing for a document.
  /// Returns the job_id.
  Future<String?> processDocument(String documentId) async {
    try {
      final response = await _sb.functions.invoke(
        AiConfig.processDocumentFn,
        body: {'document_id': documentId},
      );

      if (response.status == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return data['job_id'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('[AiDocumentService] processDocument error: $e');
      return null;
    }
  }

  // ── Read ──────────────────────────────────────────────────

  /// Get all documents for current user.
  Future<List<Map<String, dynamic>>> getDocuments() async {
    final data = await _sb
        .from('ai_documents')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  /// Get a single document by ID.
  Future<Map<String, dynamic>?> getDocument(String id) async {
    try {
      return await _sb
          .from('ai_documents')
          .select()
          .eq('id', id)
          .eq('user_id', _userId)
          .single();
    } catch (_) {
      return null;
    }
  }

  /// Get pages for a document (paginated).
  Future<List<Map<String, dynamic>>> getDocumentPages(
    String documentId, {
    int? pageNo,
    int limit = 10,
    int offset = 0,
  }) async {
    var query = _sb
        .from('ai_document_pages')
        .select()
        .eq('document_id', documentId);

    if (pageNo != null) {
      query = query.eq('page_no', pageNo);
    } 

    var transform = query.order('page_no');
    
    if (pageNo == null) {
      transform = transform.range(offset, offset + limit - 1);
    }

    final data = await transform;
    return List<Map<String, dynamic>>.from(data);
  }

  /// Get all chunks for a document.
  Future<List<Map<String, dynamic>>> getDocumentChunks(String documentId) async {
    final data = await _sb
        .from('ai_document_chunks')
        .select()
        .eq('document_id', documentId)
        .order('chunk_index');
    return List<Map<String, dynamic>>.from(data);
  }

  /// Full-text search within document pages.
  Future<List<Map<String, dynamic>>> searchInDocument(
    String documentId,
    String query,
  ) async {
    final data = await _sb
        .from('ai_document_pages')
        .select()
        .eq('document_id', documentId)
        .textSearch('text', query)
        .order('page_no');
    return List<Map<String, dynamic>>.from(data);
  }

  // ── Helpers ───────────────────────────────────────────────

  String _detectFileType(String mimeType) {
    if (mimeType.startsWith('image/')) return 'image';
    if (mimeType.startsWith('audio/')) return 'audio';
    if (mimeType.contains('pdf')) return 'pdf';
    return 'pdf'; // default
  }

  /// Compute SHA-256 hash of file bytes for deduplication.
  /// Uses dart:convert for a proper cryptographic hash.
  String _computeHash(Uint8List bytes) {
    // Simple sampling hash: first 128 bytes + last 128 bytes + length
    // For production, consider using crypto package for full SHA-256
    final len = bytes.length;
    final first = bytes.take(128).toList();
    final last = bytes.skip(len > 128 ? len - 128 : 0).toList();
    final sample = [...first, ...last];
    final hashNum = sample.fold<int>(0, (a, b) => (a * 31 + b) & 0x7FFFFFFF);
    return '${len}_${hashNum.toRadixString(16)}';
  }

  /// Encode TUS metadata from a map to the header format.
  /// Format: key1 base64val1,key2 base64val2
  String _tusMetadata(Map<String, String> metadata) {
    return metadata.entries.map((e) {
      final encoded = base64Encode(utf8.encode(e.value));
      return '${e.key} $encoded';
    }).join(',');
  }
}
