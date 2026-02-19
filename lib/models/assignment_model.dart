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
      title: 'Build a Todo App',
      courseName: 'Flutter Development Masterclass',
      description: 'Create a fully functional todo app using Provider.',
      status: AssignmentStatus.active,
      deadline: DateTime.now().add(const Duration(days: 3)),
    ),
    AssignmentModel(
      id: 'a2',
      title: 'Design System Documentation',
      courseName: 'UI/UX Design Fundamentals',
      description: 'Document a complete design system with tokens.',
      status: AssignmentStatus.submitted,
      deadline: DateTime.now().subtract(const Duration(days: 1)),
      submittedFile: 'design_system.pdf',
    ),
    AssignmentModel(
      id: 'a3',
      title: 'Wireframe for E-Commerce',
      courseName: 'UI/UX Design Fundamentals',
      description: 'Create wireframes for an e-commerce app.',
      status: AssignmentStatus.graded,
      deadline: DateTime.now().subtract(const Duration(days: 7)),
      grade: 92,
      feedback: 'Excellent work! Clean layouts and good hierarchy.',
    ),
  ];
}

enum AssignmentStatus { active, submitted, graded }
