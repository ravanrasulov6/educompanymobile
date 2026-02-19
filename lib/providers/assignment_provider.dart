import 'package:flutter/material.dart';
import '../models/assignment_model.dart';

/// Manages assignment state
class AssignmentProvider extends ChangeNotifier {
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

    await Future.delayed(const Duration(milliseconds: 500));

    _assignments = AssignmentModel.demoAssignments;
    _isLoading = false;
    notifyListeners();
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
