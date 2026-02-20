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
  final bool isLive;
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
    this.isLive = false,
    this.sections = const [],
  });

  /// Demo courses
  static final List<CourseModel> demoCourses = [
    // Live Courses
    CourseModel(
      id: 'c1',
      title: 'Flutter İnkişafı Masterklas',
      description: 'Flutter və Dart ilə istehsala hazır mobil tətbiqlər qurun.',
      thumbnailUrl: 'https://picsum.photos/seed/flutter/800/600',
      instructor: 'Sarah Müəllim',
      category: 'Mobil İnkişaf',
      rating: 4.8,
      studentsCount: 1250,
      progress: 0.65,
      totalLessons: 48,
      completedLessons: 31,
      isDemo: true,
      isLive: true,
      sections: [
        CourseSection(title: 'Başlanğıc', lessons: [
          Lesson(id: 'l1', title: 'Flutter-a Giriş', duration: '12:30', isCompleted: true),
          Lesson(id: 'l2', title: 'Mühitinizin Quraşdırılması', duration: '18:45', isCompleted: true),
          Lesson(id: 'l3', title: 'İlk Widget-iniz', duration: '22:10', isCompleted: true),
        ]),
        CourseSection(title: 'Widget-lərə Dərindən Baxış', lessons: [
          Lesson(id: 'l4', title: 'Stateful vs Stateless', duration: '15:00', isCompleted: true),
          Lesson(id: 'l5', title: 'Layout Widget-ləri', duration: '20:30', isCompleted: false),
          Lesson(id: 'l6', title: 'Xüsusi Widget-lər', duration: '25:15', isCompleted: false),
        ]),
      ],
    ),
    CourseModel(
      id: 'c2',
      title: 'UI/UX Dizayn Əsasları',
      description: 'İstifadəçi interfeysi və təcrübəsi dizaynının prinsiplərinə yiyələnin.',
      thumbnailUrl: 'https://picsum.photos/seed/design/800/600',
      instructor: 'Sarah Müəllim',
      category: 'Dizayn',
      rating: 4.6,
      studentsCount: 890,
      progress: 0.30,
      totalLessons: 36,
      completedLessons: 11,
      isDemo: true,
      isLive: true,
      sections: [
        CourseSection(title: 'Dizayn Prinsipləri', lessons: [
          Lesson(id: 'l7', title: 'Rəng Nəzəriyyəsi', duration: '14:20', isCompleted: true),
          Lesson(id: 'l8', title: 'Tipoqrafiya Əsasları', duration: '16:45', isCompleted: true),
        ]),
      ],
    ),
    // Video Courses
    CourseModel(
      id: 'c3',
      title: 'Məlumat Strukturları və Alqoritmlər',
      description: 'Kodlaşdırma müsahibələri və real layihələr üçün vacib CS konsepsiyaları.',
      thumbnailUrl: 'https://picsum.photos/seed/code/800/600',
      instructor: 'Sarah Müəllim',
      category: 'Kompüter Elmləri',
      rating: 4.9,
      studentsCount: 2100,
      progress: 0.0,
      totalLessons: 60,
      completedLessons: 0,
      isLive: false,
      sections: [
        CourseSection(title: 'Massivlər və Sətirlər', lessons: [
          Lesson(id: 'l9', title: 'Massiv Əməliyyatları', duration: '20:00', isCompleted: false),
          Lesson(id: 'l10', title: 'Sətir Manipulyasiyası', duration: '18:30', isCompleted: false),
        ]),
      ],
    ),
    CourseModel(
      id: 'c4',
      title: 'Rəqəmsal Marketinq Strategiyaları',
      description: 'Brendinizi böyütmək üçün müasir marketinq alətləri.',
      thumbnailUrl: 'https://picsum.photos/seed/marketing/800/600',
      instructor: 'Emin Bəy',
      category: 'Marketing',
      rating: 4.7,
      studentsCount: 1540,
      progress: 0.0,
      totalLessons: 24,
      completedLessons: 0,
      isLive: false,
    ),
    CourseModel(
      id: 'c5',
      title: 'Python ilə Süni İntellekt',
      description: 'AI və Machine Learning dünyasına ilk addım.',
      thumbnailUrl: 'https://picsum.photos/seed/ai/800/600',
      instructor: 'Leyla Xanım',
      category: 'Data Science',
      rating: 4.5,
      studentsCount: 3200,
      progress: 0.0,
      totalLessons: 52,
      completedLessons: 0,
      isLive: false,
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
