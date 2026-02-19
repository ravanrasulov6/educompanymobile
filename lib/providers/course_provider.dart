import 'package:flutter/material.dart';
import '../models/course_model.dart';

/// Manages course state
class CourseProvider extends ChangeNotifier {
  List<CourseModel> _courses = [];
  CourseModel? _selectedCourse;
  bool _isLoading = false;
  String? _error;

  List<CourseModel> get courses => _courses;
  CourseModel? get selectedCourse => _selectedCourse;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load courses (uses mock data)
  Future<void> loadCourses() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _courses = CourseModel.demoCourses;
    _isLoading = false;
    notifyListeners();
  }

  /// Get demo courses for guest
  List<CourseModel> get demoCourses =>
      _courses.where((c) => c.isDemo).toList();

  /// Select a course for detail view
  void selectCourse(CourseModel course) {
    _selectedCourse = course;
    notifyListeners();
  }

  /// Clear selection
  void clearSelection() {
    _selectedCourse = null;
    notifyListeners();
  }
}
