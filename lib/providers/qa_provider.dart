import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student_question_model.dart';
import '../models/ai_chat_model.dart';
import '../models/qa_config_model.dart';
import '../core/services/openai_service.dart';

/// Manages student Q&A — both AI and teacher questions
class QAProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<AIChatModel> _aiHistory = [];
  List<StudentQuestionModel> _teacherQuestions = [];
  QAConfigModel? _config;
  int _aiQuestionsUsed = 0;
  int _teacherQuestionsUsed = 0;
  bool _isLoading = false;
  bool _isAiThinking = false;
  String? _error;

  List<AIChatModel> get aiHistory => _aiHistory;
  List<StudentQuestionModel> get teacherQuestions => _teacherQuestions;
  QAConfigModel? get config => _config;
  int get aiQuestionsUsed => _aiQuestionsUsed;
  int get teacherQuestionsUsed => _teacherQuestionsUsed;
  bool get isLoading => _isLoading;
  bool get isAiThinking => _isAiThinking;
  String? get error => _error;

  int get aiQuestionsRemaining =>
      (_config?.aiQuestionLimit ?? 30) - _aiQuestionsUsed;
  int get teacherQuestionsRemaining =>
      (_config?.teacherQuestionLimit ?? 3) - _teacherQuestionsUsed;
  bool get canAskAI => aiQuestionsRemaining > 0 && (_config?.aiEnabled ?? true);
  bool get canAskTeacher =>
      teacherQuestionsRemaining > 0 && (_config?.teacherQaEnabled ?? true);

  /// Load QA data for a lesson
  Future<void> loadLessonQA(String lessonId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Load config
      final configResponse = await _supabase
          .from('lesson_qa_config')
          .select()
          .eq('lesson_id', lessonId)
          .maybeSingle();

      _config = configResponse != null
          ? QAConfigModel.fromJson(configResponse)
          : QAConfigModel(id: '', lessonId: lessonId);

      // Load AI history
      final aiResponse = await _supabase
          .from('ai_question_log')
          .select()
          .eq('lesson_id', lessonId)
          .eq('student_id', userId)
          .order('created_at');

      _aiHistory = (aiResponse as List)
          .map((j) => AIChatModel.fromJson(j as Map<String, dynamic>))
          .toList();
      _aiQuestionsUsed = _aiHistory.length;

      // Load teacher questions
      final tqResponse = await _supabase
          .from('student_questions')
          .select()
          .eq('lesson_id', lessonId)
          .eq('student_id', userId)
          .order('created_at');

      _teacherQuestions = (tqResponse as List)
          .map(
              (j) => StudentQuestionModel.fromJson(j as Map<String, dynamic>))
          .toList();
      _teacherQuestionsUsed = _teacherQuestions.length;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading QA: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ask AI a question (real OpenAI integration)
  Future<void> askAI({
    required String lessonId,
    required String question,
    required String lessonTitle,
    required String sectionTitle,
    String? courseTitle,
  }) async {
    if (!canAskAI) return;

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _isAiThinking = true;
    notifyListeners();

    try {
      // Get AI answer from OpenAI
      final answer = await OpenAIService.instance.answerQuestion(
        lessonTitle: lessonTitle,
        sectionTitle: sectionTitle,
        question: question,
        courseTitle: courseTitle,
      );

      // Save to Supabase
      final response = await _supabase.from('ai_question_log').insert({
        'lesson_id': lessonId,
        'student_id': userId,
        'question': question,
        'ai_answer': answer,
      }).select().single();

      _aiHistory.add(AIChatModel.fromJson(response));
      _aiQuestionsUsed++;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error asking AI: $e');
    } finally {
      _isAiThinking = false;
      notifyListeners();
    }
  }

  /// Send question to teacher
  Future<void> askTeacher({
    required String lessonId,
    required String question,
  }) async {
    if (!canAskTeacher) return;

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await _supabase.from('student_questions').insert({
        'lesson_id': lessonId,
        'student_id': userId,
        'question': question,
      }).select().single();

      _teacherQuestions.add(StudentQuestionModel.fromJson(response));
      _teacherQuestionsUsed++;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error asking teacher: $e');
      notifyListeners();
    }
  }

  /// Teacher: load all unanswered questions for their courses
  Future<List<StudentQuestionModel>> loadTeacherInbox() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('student_questions')
          .select('''
            *,
            student:student_id(full_name),
            lesson:lesson_id(title, section_id(title, course_id(title, instructor_id)))
          ''')
          .order('created_at', ascending: false);

      return (response as List)
          .where((q) {
            // Filter for this teacher's courses
            final lesson = q['lesson'];
            if (lesson == null) return false;
            final section = lesson['section_id'];
            if (section == null) return false;
            final course = section['course_id'];
            if (course == null) return false;
            return course['instructor_id'] == userId;
          })
          .map(
              (j) => StudentQuestionModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading teacher inbox: $e');
      return [];
    }
  }

  /// Teacher: answer a student question
  Future<bool> answerQuestion({
    required String questionId,
    required String answer,
  }) async {
    try {
      await _supabase.from('student_questions').update({
        'answer': answer,
        'is_answered': true,
        'answered_at': DateTime.now().toIso8601String(),
      }).eq('id', questionId);

      return true;
    } catch (e) {
      debugPrint('Error answering question: $e');
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
