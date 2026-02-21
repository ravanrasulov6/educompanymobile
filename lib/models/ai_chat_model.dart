/// AI chat message model
class AIChatModel {
  final String id;
  final String lessonId;
  final String studentId;
  final String question;
  final String aiAnswer;
  final DateTime createdAt;

  const AIChatModel({
    required this.id,
    required this.lessonId,
    required this.studentId,
    required this.question,
    required this.aiAnswer,
    required this.createdAt,
  });

  factory AIChatModel.fromJson(Map<String, dynamic> json) {
    return AIChatModel(
      id: json['id'] as String,
      lessonId: json['lesson_id'] as String,
      studentId: json['student_id'] as String,
      question: json['question'] as String,
      aiAnswer: json['ai_answer'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'lesson_id': lessonId,
        'student_id': studentId,
        'question': question,
        'ai_answer': aiAnswer,
      };
}
