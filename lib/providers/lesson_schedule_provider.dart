import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Lesson schedule model
class LessonScheduleItem {
  final String id;
  final String lessonId;
  final String courseId;
  final DateTime unlockDate;
  final int dayNumber;
  final String? lessonTitle;
  final String? lessonDuration;
  final bool isCompleted;

  const LessonScheduleItem({
    required this.id,
    required this.lessonId,
    required this.courseId,
    required this.unlockDate,
    required this.dayNumber,
    this.lessonTitle,
    this.lessonDuration,
    this.isCompleted = false,
  });

  bool get isUnlocked => unlockDate.isBefore(DateTime.now()) ||
      unlockDate.isAtSameMomentAs(DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ));

  bool get isToday {
    final now = DateTime.now();
    return unlockDate.year == now.year &&
        unlockDate.month == now.month &&
        unlockDate.day == now.day;
  }

  factory LessonScheduleItem.fromJson(Map<String, dynamic> json,
      {bool isCompleted = false}) {
    return LessonScheduleItem(
      id: json['id'] as String,
      lessonId: json['lesson_id'] as String,
      courseId: json['course_id'] as String,
      unlockDate: DateTime.parse(json['unlock_date'] as String),
      dayNumber: json['day_number'] as int,
      lessonTitle:
          json['lesson'] is Map ? json['lesson']['title'] as String? : null,
      lessonDuration:
          json['lesson'] is Map ? json['lesson']['duration'] as String? : null,
      isCompleted: isCompleted,
    );
  }
}

/// Manages lesson schedule — day-by-day unlock
class LessonScheduleProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<LessonScheduleItem> _schedule = [];
  bool _isLoading = false;
  String? _error;

  List<LessonScheduleItem> get schedule => _schedule;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<LessonScheduleItem> get todayLessons =>
      _schedule.where((s) => s.isToday).toList();

  List<LessonScheduleItem> get unlockedLessons =>
      _schedule.where((s) => s.isUnlocked).toList();

  List<LessonScheduleItem> get lockedLessons =>
      _schedule.where((s) => !s.isUnlocked).toList();

  /// Load schedule for a course
  Future<void> loadSchedule(String courseId) async {
    _isLoading = true;
    notifyListeners();

    final userId = _supabase.auth.currentUser?.id;

    try {
      final response = await _supabase
          .from('lesson_schedule')
          .select('''
            *,
            lesson:lesson_id(title, duration)
          ''')
          .eq('course_id', courseId)
          .order('day_number');

      // Get completed lessons
      Set<String> completedLessonIds = {};
      if (userId != null) {
        final progress = await _supabase
            .from('lesson_progress')
            .select('lesson_id')
            .eq('user_id', userId);
        completedLessonIds =
            (progress as List).map((p) => p['lesson_id'] as String).toSet();
      }

      _schedule = (response as List)
          .map((j) => LessonScheduleItem.fromJson(
                j as Map<String, dynamic>,
                isCompleted: completedLessonIds.contains(j['lesson_id']),
              ))
          .toList();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading schedule: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if a specific lesson is unlocked
  bool isLessonUnlocked(String lessonId) {
    final item = _schedule.where((s) => s.lessonId == lessonId).firstOrNull;
    if (item == null) return true; // No schedule = always unlocked
    return item.isUnlocked;
  }

  /// Get unlock date for a lesson
  DateTime? getUnlockDate(String lessonId) {
    final item = _schedule.where((s) => s.lessonId == lessonId).firstOrNull;
    return item?.unlockDate;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
