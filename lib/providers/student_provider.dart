import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class StudentProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  List<Map<String, dynamic>> _activities = [];

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get activities => _activities;

  /// Fetch dashboard stats and update the user profile in AuthProvider
  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Fetch Profile for streak and balance
      final profile = await _supabase.from('profiles').select().eq('id', userId).single();
      
      // Fetch recent activities
      final activityResponse = await _supabase
          .from('student_activities')
          .select('*, courses(title)')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(10);
      
      _activities = List<Map<String, dynamic>>.from(activityResponse);
      
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Log an activity
  Future<void> logActivity({
    required String type,
    String? courseId,
    String? description,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase.from('student_activities').insert({
        'user_id': userId,
        'activity_type': type,
        'course_id': courseId,
        'description': description,
      });
      loadDashboardData(); // Refresh list
    } catch (e) {
      debugPrint('Error logging activity: $e');
    }
  }
}
