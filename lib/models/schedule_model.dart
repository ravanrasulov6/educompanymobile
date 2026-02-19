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

  static List<ScheduleModel> get demoSchedule {
    final now = DateTime.now();
    return [
      ScheduleModel(
        id: 's1',
        title: 'Flutter State Management',
        courseName: 'Flutter Development Masterclass',
        dateTime: DateTime(now.year, now.month, now.day, 10, 0),
        durationMinutes: 90,
        type: ScheduleType.liveClass,
        hasReminder: true,
      ),
      ScheduleModel(
        id: 's2',
        title: 'Color Theory Workshop',
        courseName: 'UI/UX Design Fundamentals',
        dateTime: DateTime(now.year, now.month, now.day + 1, 14, 0),
        durationMinutes: 60,
        type: ScheduleType.liveClass,
      ),
      ScheduleModel(
        id: 's3',
        title: 'Todo App Due',
        courseName: 'Flutter Development Masterclass',
        dateTime: DateTime(now.year, now.month, now.day + 3, 23, 59),
        type: ScheduleType.assignment,
        hasReminder: true,
      ),
      ScheduleModel(
        id: 's4',
        title: 'Algorithms Quiz',
        courseName: 'Data Structures & Algorithms',
        dateTime: DateTime(now.year, now.month, now.day + 5, 9, 0),
        durationMinutes: 45,
        type: ScheduleType.exam,
      ),
    ];
  }
}

enum ScheduleType { liveClass, assignment, exam }
