/// Course model
class CourseModel {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String thumbnailUrl;
  final double progress;
  final int totalLessons;
  final int completedLessons;
  final String category;
  final double rating;
  final int studentsCount;
  final bool isDemo;
  final List<CourseSection> sections;

  const CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    this.thumbnailUrl = '',
    this.progress = 0.0,
    this.totalLessons = 0,
    this.completedLessons = 0,
    this.category = '',
    this.rating = 0.0,
    this.studentsCount = 0,
    this.isDemo = false,
    this.sections = const [],
  });

  /// Demo courses
  static final List<CourseModel> demoCourses = [
    CourseModel(
      id: 'c1',
      title: 'Flutter Development Masterclass',
      description: 'Build production-ready mobile apps with Flutter and Dart.',
      instructor: 'Sarah Teacher',
      category: 'Mobile Development',
      rating: 4.8,
      studentsCount: 1250,
      progress: 0.65,
      totalLessons: 48,
      completedLessons: 31,
      isDemo: true,
      sections: [
        CourseSection(title: 'Getting Started', lessons: [
          Lesson(id: 'l1', title: 'Introduction to Flutter', duration: '12:30', isCompleted: true),
          Lesson(id: 'l2', title: 'Setting Up Your Environment', duration: '18:45', isCompleted: true),
          Lesson(id: 'l3', title: 'Your First Widget', duration: '22:10', isCompleted: true),
        ]),
        CourseSection(title: 'Widgets Deep Dive', lessons: [
          Lesson(id: 'l4', title: 'Stateful vs Stateless', duration: '15:00', isCompleted: true),
          Lesson(id: 'l5', title: 'Layout Widgets', duration: '20:30', isCompleted: false),
          Lesson(id: 'l6', title: 'Custom Widgets', duration: '25:15', isCompleted: false),
        ]),
      ],
    ),
    CourseModel(
      id: 'c2',
      title: 'UI/UX Design Fundamentals',
      description: 'Master the principles of user interface and experience design.',
      instructor: 'Sarah Teacher',
      category: 'Design',
      rating: 4.6,
      studentsCount: 890,
      progress: 0.30,
      totalLessons: 36,
      completedLessons: 11,
      isDemo: true,
      sections: [
        CourseSection(title: 'Design Principles', lessons: [
          Lesson(id: 'l7', title: 'Color Theory', duration: '14:20', isCompleted: true),
          Lesson(id: 'l8', title: 'Typography Basics', duration: '16:45', isCompleted: true),
        ]),
      ],
    ),
    CourseModel(
      id: 'c3',
      title: 'Data Structures & Algorithms',
      description: 'Essential CS concepts for coding interviews and real projects.',
      instructor: 'Sarah Teacher',
      category: 'Computer Science',
      rating: 4.9,
      studentsCount: 2100,
      progress: 0.0,
      totalLessons: 60,
      completedLessons: 0,
      sections: [
        CourseSection(title: 'Arrays & Strings', lessons: [
          Lesson(id: 'l9', title: 'Array Operations', duration: '20:00', isCompleted: false),
          Lesson(id: 'l10', title: 'String Manipulation', duration: '18:30', isCompleted: false),
        ]),
      ],
    ),
  ];
}

/// Course section (chapter)
class CourseSection {
  final String title;
  final List<Lesson> lessons;

  const CourseSection({required this.title, this.lessons = const []});
}

/// Individual lesson
class Lesson {
  final String id;
  final String title;
  final String duration;
  final bool isCompleted;

  const Lesson({
    required this.id,
    required this.title,
    required this.duration,
    this.isCompleted = false,
  });
}
