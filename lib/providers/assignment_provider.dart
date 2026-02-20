import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/assignment_model.dart';

/// Manages assignment state
class AssignmentProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<AssignmentModel> _assignments = [];
  bool _isLoading = false;

  List<AssignmentModel> get assignments => _assignments;
  bool get isLoading => _isLoading;

  List<AssignmentModel> get activeAssignments =>
      _assignments.where((a) => a.status == AssignmentStatus.active).toList();

  List<AssignmentModel> get submittedAssignments =>
      _assignments.where((a) => a.status == AssignmentStatus.submitted).toList();

  List<AssignmentModel> get gradedAssignments =>
      _assignments.where((a) => a.status == AssignmentStatus.graded).toList();

  Future<void> loadAssignments() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      final response = await _supabase.from('assignments').select('''
            *,
            courses(title),
            assignment_submissions(*)
          ''').order('deadline', ascending: true);

      _assignments = (response as List)
          .map((json) => AssignmentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading assignments: $e');
      if (_assignments.isEmpty) {
        _assignments = AssignmentModel.demoAssignments;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void submitAssignment(String assignmentId, String filePath) {
    final index = _assignments.indexWhere((a) => a.id == assignmentId);
    if (index != -1) {
      _assignments[index] = AssignmentModel(
        id: _assignments[index].id,
        title: _assignments[index].title,
        courseName: _assignments[index].courseName,
        description: _assignments[index].description,
        status: AssignmentStatus.submitted,
        deadline: _assignments[index].deadline,
        submittedFile: filePath,
      );
      notifyListeners();
    }
  }
}
