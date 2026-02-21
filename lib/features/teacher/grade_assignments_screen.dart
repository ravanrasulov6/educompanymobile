import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'grade_assignment_sheet.dart';

class GradeAssignmentsScreen extends StatefulWidget {
  const GradeAssignmentsScreen({super.key});

  @override
  State<GradeAssignmentsScreen> createState() => _GradeAssignmentsScreenState();
}

class _GradeAssignmentsScreenState extends State<GradeAssignmentsScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _submissions = [];

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('assignment_submissions')
          .select('''
            id, answer_text, file_url, status, ai_score, teacher_score, ai_feedback, teacher_feedback, created_at,
            assignment:assignments (id, title, description, instructor_id),
            student:profiles (id, full_name, avatar_url)
          ''')
          .eq('assignment.instructor_id', userId)
          .order('created_at', ascending: false);

      // Filtering in dart since Postgrest doesn't easily support filtering on foreign table fields
      _submissions = (response as List).cast<Map<String, dynamic>>()
          .where((sub) => sub['assignment'] != null)
          .toList();
    } catch (e) {
      debugPrint('Error loading submissions: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tapşırıq Yoxlama'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _submissions.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadSubmissions,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _submissions.length,
                    itemBuilder: (_, i) => _buildSubmissionCard(_submissions[i]),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('Gözləyən tapşırıq yoxdur', style: AppTextStyles.headlineSmall),
        ],
      ),
    );
  }

  Widget _buildSubmissionCard(Map<String, dynamic> sub) {
    final assignmentTitle = sub['assignment']?['title'] as String? ?? 'Bilinməyən';
    final studentName = sub['student']?['full_name'] as String? ?? 'Bilinməyən Tələbə';
    final status = sub['status'] as String? ?? 'pending';
    final score = sub['teacher_score'] ?? sub['ai_score'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(assignmentTitle, style: AppTextStyles.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(studentName, style: AppTextStyles.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _getStatusText(status, score),
                style: TextStyle(color: _getStatusColor(status), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _openGradingSheet(sub),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'graded') return AppColors.success;
    if (status == 'failed') return AppColors.error;
    return AppColors.warning;
  }

  String _getStatusText(String status, dynamic score) {
    if (status == 'graded') return 'Yoxlanılıb ($score/100)';
    if (status == 'failed') return 'Kəsilib ($score/100)';
    return 'Gözləyir';
  }

  void _openGradingSheet(Map<String, dynamic> sub) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GradeAssignmentSheet(
        submission: sub,
        onGraded: _loadSubmissions,
      ),
    );
  }
}
