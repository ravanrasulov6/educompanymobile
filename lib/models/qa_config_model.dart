/// QA Configuration model — teacher sets limits per lesson
class QAConfigModel {
  final String id;
  final String lessonId;
  final int aiQuestionLimit;
  final int teacherQuestionLimit;
  final bool aiEnabled;
  final bool teacherQaEnabled;

  const QAConfigModel({
    required this.id,
    required this.lessonId,
    this.aiQuestionLimit = 30,
    this.teacherQuestionLimit = 3,
    this.aiEnabled = true,
    this.teacherQaEnabled = true,
  });

  factory QAConfigModel.fromJson(Map<String, dynamic> json) {
    return QAConfigModel(
      id: json['id'] as String,
      lessonId: json['lesson_id'] as String,
      aiQuestionLimit: json['ai_question_limit'] as int? ?? 30,
      teacherQuestionLimit: json['teacher_question_limit'] as int? ?? 3,
      aiEnabled: json['ai_enabled'] as bool? ?? true,
      teacherQaEnabled: json['teacher_qa_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'lesson_id': lessonId,
        'ai_question_limit': aiQuestionLimit,
        'teacher_question_limit': teacherQuestionLimit,
        'ai_enabled': aiEnabled,
        'teacher_qa_enabled': teacherQaEnabled,
      };

  QAConfigModel copyWith({
    int? aiQuestionLimit,
    int? teacherQuestionLimit,
    bool? aiEnabled,
    bool? teacherQaEnabled,
  }) {
    return QAConfigModel(
      id: id,
      lessonId: lessonId,
      aiQuestionLimit: aiQuestionLimit ?? this.aiQuestionLimit,
      teacherQuestionLimit: teacherQuestionLimit ?? this.teacherQuestionLimit,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      teacherQaEnabled: teacherQaEnabled ?? this.teacherQaEnabled,
    );
  }
}
