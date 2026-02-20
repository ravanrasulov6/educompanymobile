import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_model.dart';

/// Manages course state
class CourseProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<CourseModel> _courses = [];
  List<String> _categories = ['Hamısı'];
  Set<String> _enrolledCourseIds = {};
  String _searchQuery = '';
  String _selectedCategory = 'Hamısı';
  CourseModel? _selectedCourse;
  bool _isLoading = false;
  String? _error;
  int _streakDays = 5; // Default for demo

  List<CourseModel> get courses => _courses;
  List<String> get categories => _categories;
  Set<String> get enrolledCourseIds => _enrolledCourseIds;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  CourseModel? get selectedCourse => _selectedCourse;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get streakDays => _streakDays;

  /// Load courses from Supabase
  Future<void> loadCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Fetch Categories
      final catResponse = await _supabase.from('categories').select('name');
      _categories = ['Hamısı', ...(catResponse as List).map((c) => c['name'] as String)];

      // 2. Fetch Courses
      final response = await _supabase.from('courses').select('''
            *,
            instructor:instructor_id(full_name),
            category:category_id(name),
            price,
            course_sections(
              *,
              lessons(
                *,
                lesson_progress(is_completed)
              )
            )
          ''').order('created_at', ascending: false);

      _courses = (response as List)
          .map((json) => CourseModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading courses/categories: $e');
      if (_courses.isEmpty) {
        _courses = CourseModel.demoCourses;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load current user's enrollments
  Future<void> loadUserEnrollments(String userId) async {
    try {
      final response = await _supabase
          .from('enrollments')
          .select('course_id')
          .eq('user_id', userId);
      
      _enrolledCourseIds = (response as List)
          .map((e) => e['course_id'] as String)
          .toSet();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading enrollments: $e');
    }
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Set category
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Get filtered courses based on search and category
  List<CourseModel> get filteredCourses {
    return _courses.where((c) {
      final matchesCategory = _selectedCategory == 'Hamısı' || c.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty || 
          c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.instructor.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// Get enrolled live courses
  List<CourseModel> get enrolledLiveCourses =>
      _courses.where((c) => c.isLive && _enrolledCourseIds.contains(c.id)).toList();

  /// Get enrolled video courses
  List<CourseModel> get enrolledVideoCourses =>
      _courses.where((c) => !c.isLive && _enrolledCourseIds.contains(c.id)).toList();

  /// Get all live courses (available for browsing)
  List<CourseModel> get availableLiveCourses =>
      filteredCourses.where((c) => c.isLive).toList();

  /// Get all video courses (available for browsing)
  List<CourseModel> get availableVideoCourses =>
      filteredCourses.where((c) => !c.isLive).toList();

  /// Get popular courses (for guest or discovery)
  List<CourseModel> get popularCourses =>
      _courses.where((c) => c.rating >= 4.5).toList()
        ..sort((a, b) => b.studentsCount.compareTo(a.studentsCount));

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

  /// Enroll in a course
  Future<bool> enrollInCourse(String courseId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    // Check if it's a demo course (starts with 'c' like 'c1', 'c2' etc)
    final isDemo = courseId.startsWith('c') && courseId.length <= 3;

    try {
      if (!isDemo) {
        await _supabase.from('enrollments').insert({
          'user_id': userId,
          'course_id': courseId,
        });
      }

      _enrolledCourseIds.add(courseId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error enrolling in course: $e');
      return false;
    }
  }
}
