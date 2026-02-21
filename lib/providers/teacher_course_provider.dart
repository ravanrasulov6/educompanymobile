import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_model.dart';
import '../models/qa_config_model.dart';
import '../core/services/gumlet_service.dart';

/// Manages teacher's course CRUD operations
class TeacherCourseProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<CourseModel> _teacherCourses = [];
  bool _isLoading = false;
  String? _error;
  double _uploadProgress = 0.0;

  List<CourseModel> get teacherCourses => _teacherCourses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get uploadProgress => _uploadProgress;

  /// Load teacher's courses
  Future<void> loadTeacherCourses() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('courses')
          .select('''
            *,
            category:category_id(name),
            course_sections(
              *,
              lessons(*)
            )
          ''')
          .eq('instructor_id', userId)
          .order('created_at', ascending: false);

      _teacherCourses = (response as List)
          .map((json) => CourseModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading teacher courses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new course
  Future<String?> createCourse({
    required String title,
    required String description,
    String? categoryId,
    double price = 0.0,
    bool isFree = true,
    String? thumbnailUrl,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await _supabase.from('courses').insert({
        'title': title,
        'description': description,
        'instructor_id': userId,
        'category_id': categoryId,
        'price': price,
        'is_free': isFree,
        'thumbnail_url': thumbnailUrl ?? '',
        'status': 'draft',
      }).select().single();

      await loadTeacherCourses();
      return response['id'] as String;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating course: $e');
      notifyListeners();
      return null;
    }
  }

  /// Add a section to a course
  Future<String?> addSection({
    required String courseId,
    required String title,
    required int orderIndex,
  }) async {
    try {
      final response = await _supabase.from('course_sections').insert({
        'course_id': courseId,
        'title': title,
        'order_index': orderIndex,
      }).select().single();

      return response['id'] as String;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding section: $e');
      notifyListeners();
      return null;
    }
  }

  /// Add a lesson to a section
  Future<String?> addLesson({
    required String sectionId,
    required String title,
    String duration = '0:00',
    required int orderIndex,
  }) async {
    try {
      final response = await _supabase.from('lessons').insert({
        'section_id': sectionId,
        'title': title,
        'duration': duration,
        'order_index': orderIndex,
      }).select().single();

      return response['id'] as String;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding lesson: $e');
      notifyListeners();
      return null;
    }
  }

  /// Upload video to Gumlet and save asset_id to lesson
  Future<bool> uploadLessonVideo({
    required String lessonId,
    required File videoFile,
    required String title,
  }) async {
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      final assetId = await GumletService.instance.uploadVideo(
        videoFile: videoFile,
        title: title,
        onProgress: (progress) {
          _uploadProgress = progress;
          notifyListeners();
        },
      );

      if (assetId != null) {
        await _supabase.from('lessons').update({
          'gumlet_asset_id': assetId,
          'video_url': GumletService.instance.getPlaybackUrl(assetId),
        }).eq('id', lessonId);

        _uploadProgress = 1.0;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error uploading video: $e');
      notifyListeners();
      return false;
    }
  }

  /// Update QA config for a lesson
  Future<bool> updateQAConfig({
    required String lessonId,
    required int aiQuestionLimit,
    required int teacherQuestionLimit,
    bool aiEnabled = true,
    bool teacherQaEnabled = true,
  }) async {
    try {
      await _supabase.from('lesson_qa_config').upsert({
        'lesson_id': lessonId,
        'ai_question_limit': aiQuestionLimit,
        'teacher_question_limit': teacherQuestionLimit,
        'ai_enabled': aiEnabled,
        'teacher_qa_enabled': teacherQaEnabled,
      });
      return true;
    } catch (e) {
      debugPrint('Error updating QA config: $e');
      return false;
    }
  }

  /// Get QA config for a lesson
  Future<QAConfigModel?> getQAConfig(String lessonId) async {
    try {
      final response = await _supabase
          .from('lesson_qa_config')
          .select()
          .eq('lesson_id', lessonId)
          .maybeSingle();

      if (response != null) {
        return QAConfigModel.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching QA config: $e');
      return null;
    }
  }

  /// Publish a course
  Future<bool> publishCourse(String courseId) async {
    try {
      await _supabase
          .from('courses')
          .update({'status': 'published'}).eq('id', courseId);
      await loadTeacherCourses();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete a course
  Future<bool> deleteCourse(String courseId) async {
    try {
      await _supabase.from('courses').delete().eq('id', courseId);
      _teacherCourses.removeWhere((c) => c.id == courseId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete a lesson
  Future<bool> deleteLesson(String lessonId) async {
    try {
      await _supabase.from('lessons').delete().eq('id', lessonId);
      return true;
    } catch (e) {
      debugPrint('Error deleting lesson: $e');
      return false;
    }
  }

  /// Delete a section
  Future<bool> deleteSection(String sectionId) async {
    try {
      await _supabase.from('course_sections').delete().eq('id', sectionId);
      return true;
    } catch (e) {
      debugPrint('Error deleting section: $e');
      return false;
    }
  }

  /// Get categories list
  Future<List<Map<String, String>>> getCategories() async {
    try {
      final response = await _supabase.from('categories').select('id, name');
      return (response as List)
          .map((c) => <String, String>{
                'id': c['id'] as String,
                'name': c['name'] as String,
              })
          .toList();
    } catch (e) {
      return [];
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
