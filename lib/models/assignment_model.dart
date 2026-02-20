/// Assignment model
class AssignmentModel {
  final String id;
  final String title;
  final String courseName;
  final String description;
  final AssignmentStatus status;
  final DateTime deadline;
  final double? grade;
  final String? feedback;
  final String? submittedFile;

  const AssignmentModel({
    required this.id,
    required this.title,
    required this.courseName,
    this.description = '',
    required this.status,
    required this.deadline,
    this.grade,
    this.feedback,
    this.submittedFile,
  });

  bool get isOverdue =>
      status == AssignmentStatus.active &&
      DateTime.now().isAfter(deadline);

  static final List<AssignmentModel> demoAssignments = [
    AssignmentModel(
      id: 'a1',
      title: 'Todo Tətbiqi Qurun',
      courseName: 'Flutter İnkişafı Masterklas',
      description: 'Provider istifadə edərək tam funksional todo tətbiqi yaradın.',
      status: AssignmentStatus.active,
      deadline: DateTime.now().add(const Duration(days: 3)),
    ),
    AssignmentModel(
      id: 'a2',
      title: 'Dizayn Sistemi Sənədləşdirilməsi',
      courseName: 'UI/UX Dizayn Əsasları',
      description: 'Tokenlərlə tam dizayn sistemini sənədləşdirin.',
      status: AssignmentStatus.submitted,
      deadline: DateTime.now().subtract(const Duration(days: 1)),
      submittedFile: 'design_system.pdf',
    ),
    AssignmentModel(
      id: 'a3',
      title: 'E-Ticarət üçün Wireframe',
      courseName: 'UI/UX Dizayn Əsasları',
      description: 'E-ticarət tətbiqi üçün wireframe-lər yaradın.',
      status: AssignmentStatus.graded,
      deadline: DateTime.now().subtract(const Duration(days: 7)),
      grade: 92,
      feedback: 'Mükəmməl iş! Təmiz düzənlər və yaxşı iyerarxiya.',
    ),
  ];
}

enum AssignmentStatus { active, submitted, graded }
