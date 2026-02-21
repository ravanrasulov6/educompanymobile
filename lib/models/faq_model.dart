/// FAQ model for per-section FAQs
class FaqModel {
  final String id;
  final String sectionId;
  final String question;
  final String answer;
  final String category;
  final int orderIndex;
  final int helpfulCount;
  final String? createdBy;

  const FaqModel({
    required this.id,
    required this.sectionId,
    required this.question,
    required this.answer,
    this.category = 'general',
    this.orderIndex = 0,
    this.helpfulCount = 0,
    this.createdBy,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['id'] as String,
      sectionId: json['section_id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      category: json['category'] as String? ?? 'general',
      orderIndex: json['order_index'] as int? ?? 0,
      helpfulCount: json['helpful_count'] as int? ?? 0,
      createdBy: json['created_by'] as String?,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'section_id': sectionId,
        'question': question,
        'answer': answer,
        'category': category,
        'order_index': orderIndex,
        'created_by': createdBy,
      };

  /// Category display name
  String get categoryLabel {
    switch (category) {
      case 'general':
        return 'Ümumi';
      case 'technical':
        return 'Texniki';
      case 'practical':
        return 'Praktiki';
      default:
        return 'Ümumi';
    }
  }
}
