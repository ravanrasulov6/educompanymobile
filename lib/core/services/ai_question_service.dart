import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for AI question generation and retrieval.
class AiQuestionService {
  AiQuestionService._();
  static final AiQuestionService instance = AiQuestionService._();

  SupabaseClient get _sb => Supabase.instance.client;
  String get _userId => _sb.auth.currentUser!.id;

  /// Generate questions from document or transcript.
  Future<Map<String, dynamic>?> generateQuestions({
    String? documentId,
    String? transcriptId,
    String questionType = 'mcq',
    int count = 5,
    String difficulty = 'medium',
    int? pageStart,
    int? pageEnd,
  }) async {
    try {
      final response = await _sb.functions.invoke(
        'generate-questions',
        body: {
          'document_id': documentId,
          'transcript_id': transcriptId,
          'question_type': questionType,
          'count': count,
          'difficulty': difficulty,
          'page_start': pageStart,
          'page_end': pageEnd,
        },
      );

      if (response.status == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('[AiQuestionService] generateQuestions error: $e');
      return null;
    }
  }

  /// Get questions for a document.
  Future<List<Map<String, dynamic>>> getQuestionsForDocument(String documentId) async {
    final data = await _sb
        .from('ai_questions')
        .select()
        .eq('document_id', documentId)
        .eq('user_id', _userId)
        .order('created_at');
    return List<Map<String, dynamic>>.from(data);
  }

  /// Get questions for a transcript.
  Future<List<Map<String, dynamic>>> getQuestionsForTranscript(String transcriptId) async {
    final data = await _sb
        .from('ai_questions')
        .select()
        .eq('transcript_id', transcriptId)
        .eq('user_id', _userId)
        .order('created_at');
    return List<Map<String, dynamic>>.from(data);
  }

  /// Get all questions for current user.
  Future<List<Map<String, dynamic>>> getAllQuestions({String? questionType}) async {
    var query = _sb
        .from('ai_questions')
        .select()
        .eq('user_id', _userId);

    if (questionType != null) {
      query = query.eq('question_type', questionType);
    }

    final data = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  /// Delete a question.
  Future<void> deleteQuestion(String questionId) async {
    await _sb
        .from('ai_questions')
        .delete()
        .eq('id', questionId)
        .eq('user_id', _userId);
  }
}
