/// Course resource model (paid/free materials inside a course)
class CourseResourceModel {
  final String id;
  final String courseId;
  final String? sectionId;
  final String title;
  final String? description;
  final ResourceType resourceType;
  final String fileUrl;
  final double price;
  final bool isFree;
  final int downloadCount;
  final DateTime createdAt;
  // Client-side state
  final bool isPurchased;

  const CourseResourceModel({
    required this.id,
    required this.courseId,
    this.sectionId,
    required this.title,
    this.description,
    required this.resourceType,
    required this.fileUrl,
    this.price = 0.0,
    this.isFree = false,
    this.downloadCount = 0,
    required this.createdAt,
    this.isPurchased = false,
  });

  factory CourseResourceModel.fromJson(Map<String, dynamic> json,
      {bool isPurchased = false}) {
    return CourseResourceModel(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      sectionId: json['section_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      resourceType: _parseType(json['resource_type'] as String?),
      fileUrl: json['file_url'] as String,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      isFree: json['is_free'] as bool? ?? false,
      downloadCount: json['download_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      isPurchased: isPurchased,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'course_id': courseId,
        'section_id': sectionId,
        'title': title,
        'description': description,
        'resource_type': resourceType.name,
        'file_url': fileUrl,
        'price': price,
        'is_free': isFree,
      };

  bool get canAccess => isFree || isPurchased;

  String get typeLabel {
    switch (resourceType) {
      case ResourceType.pdf:
        return '📄 PDF';
      case ResourceType.template:
        return '📋 Şablon';
      case ResourceType.source_code:
        return '💻 Kod';
      case ResourceType.asset:
        return '🎨 Asset';
      case ResourceType.other:
        return '📦 Digər';
    }
  }

  static ResourceType _parseType(String? type) {
    switch (type) {
      case 'pdf':
        return ResourceType.pdf;
      case 'template':
        return ResourceType.template;
      case 'source_code':
        return ResourceType.source_code;
      case 'asset':
        return ResourceType.asset;
      default:
        return ResourceType.other;
    }
  }
}

enum ResourceType { pdf, template, source_code, asset, other }
