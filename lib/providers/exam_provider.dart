import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exam_model.dart';

/// Manages exam state
class ExamProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<ExamModel> _exams = [];
  ExamModel? _currentExam;
  int _currentQuestionIndex = 0;
  Map<String, int> _answers = {};
  bool _isLoading = false;
  bool _examFinished = false;
  double? _lastScore;

  List<ExamModel> get exams => _exams;
  ExamModel? get currentExam => _currentExam;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<String, int> get answers => _answers;
  bool get isLoading => _isLoading;
  bool get examFinished => _examFinished;
  double? get lastScore => _lastScore;

  List<ExamModel> get availableExams =>
      _exams.where((e) => e.status == ExamStatus.available).toList();

  List<ExamModel> get completedExams =>
      _exams.where((e) => e.status == ExamStatus.completed).toList();

  Future<void> loadExams() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase.from('exams').select('''
            *,
            courses(title),
            exam_questions(*),
            exam_results(*)
          ''');

      _exams = (response as List)
          .map((json) => ExamModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading exams: $e');
      if (_exams.isEmpty) {
        _exams = ExamModel.demoExams;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startExam(ExamModel exam) {
    _currentExam = exam;
    _currentQuestionIndex = 0;
    _answers = {};
    _examFinished = false;
    _lastScore = null;
    notifyListeners();
  }

  void answerQuestion(String questionId, int optionIndex) {
    _answers[questionId] = optionIndex;
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentExam != null &&
        _currentQuestionIndex < _currentExam!.questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  void finishExam() {
    if (_currentExam == null) return;

    int correct = 0;
    for (final q in _currentExam!.questions) {
      if (_answers[q.id] == q.correctIndex) {
        correct++;
      }
    }
    _lastScore = (correct / _currentExam!.questions.length) * 100;
    _examFinished = true;
    notifyListeners();
  }

  void resetExam() {
    _currentExam = null;
    _currentQuestionIndex = 0;
    _answers = {};
    _examFinished = false;
    _lastScore = null;
    notifyListeners();
  }
}
