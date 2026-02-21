import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/premium_button.dart';
import '../../providers/teacher_course_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Dynamic create assignment screen with Supabase data
class CreateAssignmentScreen extends StatefulWidget {
  const CreateAssignmentScreen({super.key});

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final _supabase = Supabase.instance.client;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  List<Map<String, dynamic>> _courses = [];
  String? _selectedCourseId;
  DateTime? _dueDate;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await _supabase
          .from('courses')
          .select('id, title')
          .eq('instructor_id', userId)
          .order('created_at', ascending: false);
      _courses = (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error loading courses: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Yeni Tapşırıq', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 24),

          Text('Başlıq', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Tapşırıq başlığı',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),

          Text('Kurs', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Kurs seçin',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            value: _selectedCourseId,
            items: _courses
                .map((c) => DropdownMenuItem(
                      value: c['id'] as String,
                      child: Text(c['title'] as String,
                          overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selectedCourseId = v),
          ),
          const SizedBox(height: 20),

          Text('Təsvir', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _descController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Tapşırığı təsvir edin...',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),

          Text('Son tarix', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          TextField(
            readOnly: true,
            controller: TextEditingController(
              text: _dueDate != null
                  ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                  : '',
            ),
            decoration: InputDecoration(
              hintText: 'Tarix seçin',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate:
                    DateTime.now().add(const Duration(days: 7)),
                firstDate: DateTime.now(),
                lastDate:
                    DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) setState(() => _dueDate = date);
            },
          ),
          const SizedBox(height: 32),

          PremiumButton(
            label: 'Tapşırıq Yarat',
            isGradient: true,
            icon: Icons.add_task_rounded,
            isLoading: _isSubmitting,
            height: 52,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başlıq daxil edin')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _supabase.from('assignments').insert({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'course_id': _selectedCourseId,
        'deadline': _dueDate?.toIso8601String(),
        'instructor_id': _supabase.auth.currentUser?.id,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Tapşırıq yaradıldı!'),
            backgroundColor: AppColors.success,
          ),
        );
        _titleController.clear();
        _descController.clear();
        setState(() {
          _selectedCourseId = null;
          _dueDate = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xəta: $e'), backgroundColor: AppColors.error),
        );
      }
    }
    if (mounted) setState(() => _isSubmitting = false);
  }
}
