/// Exam model
class ExamModel {
  final String id;
  final String title;
  final String courseName;
  final int totalQuestions;
  final int durationMinutes;
  final ExamStatus status;
  final double? score;
  final List<ExamQuestion> questions;

  const ExamModel({
    required this.id,
    required this.title,
    required this.courseName,
    required this.totalQuestions,
    required this.durationMinutes,
    this.status = ExamStatus.available,
    this.score,
    this.questions = const [],
  });

  static final List<ExamModel> demoExams = [
    ExamModel(
      id: 'e1',
      title: 'Flutter Əsasları Viktorinası',
      courseName: 'Flutter İnkişafı Masterklas',
      totalQuestions: 20,
      durationMinutes: 30,
      status: ExamStatus.available,
      questions: ExamQuestion.demoQuestions,
    ),
    ExamModel(
      id: 'e2',
      title: 'Dizayn Prinsipləri Testi',
      courseName: 'UI/UX Dizayn Əsasları',
      totalQuestions: 15,
      durationMinutes: 20,
      status: ExamStatus.completed,
      score: 85.0,
    ),
    ExamModel(
      id: 'e3',
      title: 'Alqoritmlər Aralıq İmtahanı',
      courseName: 'Məlumat Strukturları və Alqoritmlər',
      totalQuestions: 30,
      durationMinutes: 45,
      status: ExamStatus.available,
    ),
  ];
}

enum ExamStatus { available, inProgress, completed }

/// Exam question
class ExamQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;

  const ExamQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  static const List<ExamQuestion> demoQuestions = [
    ExamQuestion(
      id: 'q1',
      question: 'Flutter-da bütün widget-lər üçün əsas klass hansıdır?',
      options: ['Widget', 'Component', 'View', 'Element'],
      correctIndex: 0,
    ),
    ExamQuestion(
      id: 'q2',
      question: 'Vəziyyət dəyişdikdə hansı widget yenidən qurulur?',
      options: ['StatelessWidget', 'StatefulWidget', 'InheritedWidget', 'Container'],
      correctIndex: 1,
    ),
    ExamQuestion(
      id: 'q3',
      question: 'Widget-də UI yaratmaq üçün hansı metod çağırılır?',
      options: ['render()', 'create()', 'build()', 'draw()'],
      correctIndex: 2,
    ),
    ExamQuestion(
      id: 'q4',
      question: 'Hansı layout widget-i uşaqları şaquli massivdə yerləşdirir?',
      options: ['Row', 'Stack', 'Column', 'Wrap'],
      correctIndex: 2,
    ),
    ExamQuestion(
      id: 'q5',
      question: 'Vəziyyətin idarə edilməsi (state management) üçün adətən hansı paket istifadə olunur?',
      options: ['Redux', 'Provider', 'MobX', 'Hamısı'],
      correctIndex: 3,
    ),
  ];
}
