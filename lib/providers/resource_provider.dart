import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_resource_model.dart';

/// Manages course resources — purchase, download, CRUD
class ResourceProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<CourseResourceModel> _resources = [];
  Set<String> _purchasedIds = {};
  bool _isLoading = false;
  String? _error;

  List<CourseResourceModel> get resources => _resources;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load resources for a course
  Future<void> loadCourseResources(String courseId) async {
    _isLoading = true;
    notifyListeners();

    final userId = _supabase.auth.currentUser?.id;

    try {
      // Fetch resources
      final response = await _supabase
          .from('course_resources')
          .select()
          .eq('course_id', courseId)
          .order('created_at');

      // Fetch user's purchases for this course
      if (userId != null) {
        final purchases = await _supabase
            .from('resource_purchases')
            .select('resource_id')
            .eq('user_id', userId);

        _purchasedIds =
            (purchases as List).map((p) => p['resource_id'] as String).toSet();
      }

      _resources = (response as List)
          .map((j) => CourseResourceModel.fromJson(
                j as Map<String, dynamic>,
                isPurchased: _purchasedIds.contains(j['id']),
              ))
          .toList();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading resources: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Purchase a resource
  Future<bool> purchaseResource(String resourceId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      await _supabase.from('resource_purchases').insert({
        'resource_id': resourceId,
        'user_id': userId,
      });

      _purchasedIds.add(resourceId);

      // Update local state
      final index = _resources.indexWhere((r) => r.id == resourceId);
      if (index >= 0) {
        final old = _resources[index];
        _resources[index] = CourseResourceModel(
          id: old.id,
          courseId: old.courseId,
          sectionId: old.sectionId,
          title: old.title,
          description: old.description,
          resourceType: old.resourceType,
          fileUrl: old.fileUrl,
          price: old.price,
          isFree: old.isFree,
          downloadCount: old.downloadCount + 1,
          createdAt: old.createdAt,
          isPurchased: true,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error purchasing resource: $e');
      notifyListeners();
      return false;
    }
  }

  /// Add a resource (teacher)
  Future<bool> addResource({
    required String courseId,
    String? sectionId,
    required String title,
    String? description,
    required String resourceType,
    required String fileUrl,
    double price = 0.0,
    bool isFree = false,
  }) async {
    try {
      await _supabase.from('course_resources').insert({
        'course_id': courseId,
        'section_id': sectionId,
        'title': title,
        'description': description,
        'resource_type': resourceType,
        'file_url': fileUrl,
        'price': price,
        'is_free': isFree,
      });

      await loadCourseResources(courseId);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding resource: $e');
      notifyListeners();
      return false;
    }
  }

  /// Delete a resource (teacher)
  Future<bool> deleteResource(String resourceId, String courseId) async {
    try {
      await _supabase.from('course_resources').delete().eq('id', resourceId);
      _resources.removeWhere((r) => r.id == resourceId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting resource: $e');
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
