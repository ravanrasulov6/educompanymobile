import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_keys.dart';

/// AI service — all calls routed through Supabase Edge Functions.
/// NO direct AI provider calls from Flutter. API keys are server-side only.
class OpenAIService {
  OpenAIService._();
  static final OpenAIService instance = OpenAIService._();

  SupabaseClient get _supabase => Supabase.instance.client;

  /// Generic Edge Function caller with retry
  Future<Map<String, dynamic>?> _callEdgeFunction({
    required String functionName,
    required Map<String, dynamic> body,
    int maxRetries = 2,
  }) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final response = await _supabase.functions.invoke(
          functionName,
          body: body,
          headers: EnvKeys.headers,
        );

        if (response.status == 200) {
          if (response.data is Map<String, dynamic>) {
            return response.data as Map<String, dynamic>;
          }
          if (response.data is String) {
            return jsonDecode(response.data as String) as Map<String, dynamic>;
          }
          return {'data': response.data};
        } else if (response.status == 429) {
          debugPrint('[$functionName] Rate limited (attempt ${attempt + 1})');
          await Future.delayed(Duration(seconds: (attempt + 1) * 3));
          continue;
        } else {
          debugPrint('[$functionName] Error: ${response.status}');
          return null;
        }
      } catch (e) {
        debugPrint('[$functionName] Exception: $e');
        if (attempt < maxRetries - 1) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
        return null;
      }
    }
    return null;
  }

  /// Generate FAQs (backward compatible)
  Future<List<Map<String, String>>> generateFaqs({
    required String sectionTitle,
    required List<String> lessonTitles,
    int count = 15,
  }) async {
    final result = await _callEdgeFunction(
      functionName: 'ai-chat',
      body: {
        'action': 'generate_faqs',
        'section_title': sectionTitle,
        'lesson_titles': lessonTitles,
        'count': count,
      },
    );

    if (result != null && result['faqs'] != null) {
      try {
        final parsed = (result['faqs'] as List);
        return parsed
            .map((item) => <String, String>{
                  'question': item['question'] as String,
                  'answer': item['answer'] as String,
                  'category': item['category'] as String? ?? 'general',
                })
            .toList();
      } catch (e) {
        debugPrint('FAQ parse error: $e');
      }
    }
    return [];
  }

  /// Answer student question (backward compatible)
  Future<String> answerQuestion({
    required String lessonTitle,
    required String sectionTitle,
    required String question,
    String? courseTitle,
  }) async {
    final result = await _callEdgeFunction(
      functionName: 'ai-chat',
      body: {
        'action': 'answer_question',
        'lesson_title': lessonTitle,
        'section_title': sectionTitle,
        'question': question,
        'course_title': courseTitle,
      },
    );

    return result?['answer'] as String? ??
        'Bağışlayın, hazırda cavab verə bilmirəm.';
  }

  /// Generate course description (backward compatible)
  Future<String> generateCourseDescription({
    required String courseTitle,
    String? category,
    List<String>? sectionTitles,
  }) async {
    final result = await _callEdgeFunction(
      functionName: 'ai-chat',
      body: {
        'action': 'generate_description',
        'course_title': courseTitle,
        'category': category,
        'section_titles': sectionTitles,
      },
    );

    return result?['description'] as String? ?? '';
  }

  /// Generate Exam Questions (backward compatible)
  Future<List<Map<String, dynamic>>> generateExamQuestions({
    required String topicOrText,
    int count = 5,
    String? examType,
    String? penaltyRule,
    String? base64Image,
    String? imageMime,
  }) async {
    final result = await _callEdgeFunction(
      functionName: 'ai-chat',
      body: {
        'action': 'generate_exam_questions',
        'topic_or_text': topicOrText,
        'count': count,
        'exam_type': examType,
        'penalty_rule': penaltyRule,
        'base64_image': base64Image,
        'image_mime': imageMime,
      },
    );

    if (result != null && result['questions'] != null) {
      try {
        final parsed = (result['questions'] as List);
        return parsed
            .map((item) => <String, dynamic>{
                  'question': item['question'],
                  'options': List<String>.from(item['options'] as List),
                  'correctIndex': item['correctIndex'],
                })
            .toList();
      } catch (e) {
        debugPrint('Exam question parse error: $e');
      }
    }
    return [];
  }

  /// Grade Assignment Submission (backward compatible)
  Future<Map<String, dynamic>> gradeAssignment({
    required String assignmentTitle,
    required String assignmentDescription,
    required String studentAnswer,
  }) async {
    final result = await _callEdgeFunction(
      functionName: 'ai-chat',
      body: {
        'action': 'grade_assignment',
        'assignment_title': assignmentTitle,
        'assignment_description': assignmentDescription,
        'student_answer': studentAnswer,
      },
    );

    if (result != null &&
        result['score'] != null &&
        result['feedback'] != null) {
      return result;
    }
    return {'score': 0, 'feedback': 'Sistem xətası: Yoxlama uğursuz oldu.'};
  }
}
