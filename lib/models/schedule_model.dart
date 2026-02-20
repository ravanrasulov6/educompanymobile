/// Schedule / session model
class ScheduleModel {
  final String id;
  final String title;
  final String courseName;
  final DateTime dateTime;
  final int durationMinutes;
  final ScheduleType type;
  final bool hasReminder;

  const ScheduleModel({
    required this.id,
    required this.title,
    required this.courseName,
    required this.dateTime,
    this.durationMinutes = 60,
    required this.type,
    this.hasReminder = false,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as String,
      title: json['title'] as String,
      courseName: json['course']?['title'] as String? ?? 'Naməlum Kurs',
      dateTime: DateTime.parse(json['date_time'] as String),
      durationMinutes: json['duration_minutes'] as int? ?? 60,
      type: _parseType(json['type'] as String),
      hasReminder: json['has_reminder'] as bool? ?? false,
    );
  }

  static ScheduleType _parseType(String type) {
    switch (type) {
      case 'liveClass':
        return ScheduleType.liveClass;
      case 'assignment':
        return ScheduleType.assignment;
      case 'exam':
        return ScheduleType.exam;
      default:
        return ScheduleType.liveClass;
    }
  }

  static List<ScheduleModel> get demoSchedule {
    final now = DateTime.now();
    return [
      ScheduleModel(
        id: 's1',
        title: 'Flutter State Management',
        courseName: 'Flutter İnkişafı Masterklas',
        dateTime: DateTime(now.year, now.month, now.day, 10, 0),
        durationMinutes: 90,
        type: ScheduleType.liveClass,
        hasReminder: true,
      ),
      ScheduleModel(
        id: 's2',
        title: 'Rəng Nəzəriyyəsi Seminarı',
        courseName: 'UI/UX Dizayn Əsasları',
        dateTime: DateTime(now.year, now.month, now.day + 1, 14, 0),
        durationMinutes: 60,
        type: ScheduleType.liveClass,
      ),
      ScheduleModel(
        id: 's3',
        title: 'Todo Tətbiqi Təhvili',
        courseName: 'Flutter İnkişafı Masterklas',
        dateTime: DateTime(now.year, now.month, now.day + 3, 23, 59),
        type: ScheduleType.assignment,
        hasReminder: true,
      ),
      ScheduleModel(
        id: 's4',
        title: 'Alqoritmlər Viktorinası',
        courseName: 'Məlumat Strukturları və Alqoritmlər',
        dateTime: DateTime(now.year, now.month, now.day + 5, 9, 0),
        durationMinutes: 45,
        type: ScheduleType.exam,
      ),
    ];
  }
}

enum ScheduleType { liveClass, assignment, exam }
