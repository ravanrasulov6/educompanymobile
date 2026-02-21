/// Student question to teacher
class StudentQuestionModel {
  final String id;
  final String lessonId;
  final String studentId;
  final String question;
  final String? answer;
  final bool isAnswered;
  final DateTime createdAt;
  final DateTime? answeredAt;
  // Joined fields
  final String? studentName;
  final String? lessonTitle;
  final String? courseName;

  const StudentQuestionModel({
    required this.id,
    required this.lessonId,
    required this.studentId,
    required this.question,
    this.answer,
    this.isAnswered = false,
    required this.createdAt,
    this.answeredAt,
    this.studentName,
    this.lessonTitle,
    this.courseName,
  });

  factory StudentQuestionModel.fromJson(Map<String, dynamic> json) {
    return StudentQuestionModel(
      id: json['id'] as String,
      lessonId: json['lesson_id'] as String,
      studentId: json['student_id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String?,
      isAnswered: json['is_answered'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      answeredAt: json['answered_at'] != null
          ? DateTime.parse(json['answered_at'] as String)
          : null,
      studentName: json['student'] is Map
          ? json['student']['full_name'] as String?
          : null,
      lessonTitle: json['lesson'] is Map
          ? json['lesson']['title'] as String?
          : null,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'lesson_id': lessonId,
        'student_id': studentId,
        'question': question,
      };
}
