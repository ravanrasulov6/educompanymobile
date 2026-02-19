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
      title: 'Flutter Basics Quiz',
      courseName: 'Flutter Development Masterclass',
      totalQuestions: 20,
      durationMinutes: 30,
      status: ExamStatus.available,
      questions: ExamQuestion.demoQuestions,
    ),
    ExamModel(
      id: 'e2',
      title: 'Design Principles Test',
      courseName: 'UI/UX Design Fundamentals',
      totalQuestions: 15,
      durationMinutes: 20,
      status: ExamStatus.completed,
      score: 85.0,
    ),
    ExamModel(
      id: 'e3',
      title: 'Algorithms Mid-Term',
      courseName: 'Data Structures & Algorithms',
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
      question: 'What is the base class for all widgets in Flutter?',
      options: ['Widget', 'Component', 'View', 'Element'],
      correctIndex: 0,
    ),
    ExamQuestion(
      id: 'q2',
      question: 'Which widget rebuilds when state changes?',
      options: ['StatelessWidget', 'StatefulWidget', 'InheritedWidget', 'Container'],
      correctIndex: 1,
    ),
    ExamQuestion(
      id: 'q3',
      question: 'What method is called to create the UI in a widget?',
      options: ['render()', 'create()', 'build()', 'draw()'],
      correctIndex: 2,
    ),
    ExamQuestion(
      id: 'q4',
      question: 'Which layout widget places children in a vertical array?',
      options: ['Row', 'Stack', 'Column', 'Wrap'],
      correctIndex: 2,
    ),
    ExamQuestion(
      id: 'q5',
      question: 'What package is commonly used for state management?',
      options: ['Redux', 'Provider', 'MobX', 'All of the above'],
      correctIndex: 3,
    ),
  ];
}
