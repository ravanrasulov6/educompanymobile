import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_keys.dart';

/// Service for document/transcript/question export (PDF/DOCX).
class AiExportService {
  AiExportService._();
  static final AiExportService instance = AiExportService._();

  SupabaseClient get _sb => Supabase.instance.client;
  String get _userId => _sb.auth.currentUser!.id;

  /// Trigger export generation. Returns download URL and export ID.
  Future<Map<String, dynamic>?> exportDocument({
    required String sourceType,
    required String sourceId,
    String format = 'pdf',
    bool includeQuestions = false,
  }) async {
    try {
      final response = await _sb.functions.invoke(
        'export-document',
        body: {
          'source_type': sourceType,
          'source_id': sourceId,
          'format': format,
          'include_questions': includeQuestions,
        },
        headers: EnvKeys.headers,
      );

      if (response.status == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('[AiExportService] export error: $e');
      return null;
    }
  }

  /// Get all exports for current user.
  Future<List<Map<String, dynamic>>> getExports() async {
    final data = await _sb
        .from('ai_exports')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  /// Get a signed download URL for an export.
  Future<String?> getDownloadUrl(String storagePath) async {
    try {
      final result = await _sb.storage
          .from('ai-exports')
          .createSignedUrl(storagePath, 3600);
      return result;
    } catch (e) {
      debugPrint('[AiExportService] getDownloadUrl error: $e');
      return null;
    }
  }

  /// Get summarization of a document or transcript.
  Future<String?> summarize({
    String? documentId,
    String? transcriptId,
  }) async {
    try {
      final response = await _sb.functions.invoke(
        'summarize',
        body: {
          'document_id': documentId,
          'transcript_id': transcriptId,
        },
        headers: EnvKeys.headers,
      );

      if (response.status == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return data['summary'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('[AiExportService] summarize error: $e');
      return null;
    }
  }
}
