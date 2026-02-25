import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for audio upload, recording management, and transcript retrieval.
class AiTranscriptService {
  AiTranscriptService._();
  static final AiTranscriptService instance = AiTranscriptService._();

  SupabaseClient get _sb => Supabase.instance.client;
  String get _userId => _sb.auth.currentUser!.id;

  /// Upload audio file and create transcript record.
  /// Returns the transcript record (STT will be triggered separately).
  Future<Map<String, dynamic>> uploadAudio({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    String language = 'az',
    String? title,
  }) async {
    final storagePath = '$_userId/audio_${DateTime.now().millisecondsSinceEpoch}_$fileName';

    // 1. Upload to storage
    await _sb.storage.from('ai-uploads').uploadBinary(
      storagePath,
      bytes,
      fileOptions: FileOptions(contentType: mimeType),
    );

    // 2. Create audio document record
    final doc = await _sb.from('ai_documents').insert({
      'user_id': _userId,
      'file_name': fileName,
      'file_type': 'audio',
      'file_size_bytes': bytes.length,
      'storage_path': storagePath,
      'mime_type': mimeType,
    }).select().single();

    // 3. Create transcript record
    final transcript = await _sb.from('ai_transcripts').insert({
      'user_id': _userId,
      'document_id': doc['id'],
      'title': title ?? fileName,
      'storage_path': storagePath,
      'language': language,
      'status': 'pending',
    }).select().single();

    debugPrint('[AiTranscriptService] Transcript created: ${transcript['id']}');
    return transcript;
  }

  /// Trigger speech-to-text processing.
  Future<String?> processTranscript(String transcriptId) async {
    try {
      final response = await _sb.functions.invoke(
        'speech-to-text',
        body: {'transcript_id': transcriptId},
      );

      if (response.status == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return data['job_id'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('[AiTranscriptService] processTranscript error: $e');
      return null;
    }
  }

  /// Get all transcripts for current user.
  Future<List<Map<String, dynamic>>> getTranscripts() async {
    final data = await _sb
        .from('ai_transcripts')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  /// Get a single transcript by ID.
  Future<Map<String, dynamic>?> getTranscript(String id) async {
    try {
      return await _sb
          .from('ai_transcripts')
          .select()
          .eq('id', id)
          .eq('user_id', _userId)
          .single();
    } catch (_) {
      return null;
    }
  }
}
