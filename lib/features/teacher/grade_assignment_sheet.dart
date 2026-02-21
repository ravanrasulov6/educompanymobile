import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/openai_service.dart';

class GradeAssignmentSheet extends StatefulWidget {
  final Map<String, dynamic> submission;
  final VoidCallback onGraded;

  const GradeAssignmentSheet({
    super.key,
    required this.submission,
    required this.onGraded,
  });

  @override
  State<GradeAssignmentSheet> createState() => _GradeAssignmentSheetState();
}

class _GradeAssignmentSheetState extends State<GradeAssignmentSheet> {
  final _supabase = Supabase.instance.client;
  final _scoreController = TextEditingController();
  final _feedbackController = TextEditingController();
  
  bool _isAIGrading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final score = widget.submission['teacher_score'] ?? widget.submission['ai_score'];
    final feedback = widget.submission['teacher_feedback'] ?? widget.submission['ai_feedback'];
    
    if (score != null) _scoreController.text = score.toString();
    if (feedback != null) _feedbackController.text = feedback.toString();
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _gradeWithAI() async {
    final assignment = widget.submission['assignment'];
    final answerText = widget.submission['answer_text'];

    if (answerText == null || answerText.toString().trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tələbə mətn daxil etməyib')),
      );
      return;
    }

    setState(() => _isAIGrading = true);

    try {
      final result = await OpenAIService.instance.gradeAssignment(
        assignmentTitle: assignment['title'] ?? '',
        assignmentDescription: assignment['description'] ?? '',
        studentAnswer: answerText,
      );

      setState(() {
        _scoreController.text = result['score'].toString();
        _feedbackController.text = result['feedback'].toString();
      });

      // Optionally save AI score directly to DB
      await _supabase.from('assignment_submissions').update({
        'ai_score': result['score'],
        'ai_feedback': result['feedback'],
      }).eq('id', widget.submission['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ AI yoxladı! Rəyi nəzərdən keçirib yadda saxlayın.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xəta: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAIGrading = false);
    }
  }

  Future<void> _saveGrade() async {
    final scoreText = _scoreController.text.trim();
    final feedback = _feedbackController.text.trim();

    if (scoreText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Qiymət (bal) daxil edin')),
      );
      return;
    }

    final score = int.tryParse(scoreText);
    if (score == null || score < 0 || score > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bal 0-100 arasında olmalıdır')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final status = score >= 60 ? 'graded' : 'failed'; // Assuming passing is 60

      await _supabase.from('assignment_submissions').update({
        'teacher_score': score,
        'teacher_feedback': feedback,
        'status': status,
      }).eq('id', widget.submission['id']);

      if (mounted) {
        widget.onGraded();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Qiymət yadda saxlanıldı'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xəta: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentName = widget.submission['student']?['full_name'] as String? ?? 'Tələbə';
    final answerText = widget.submission['answer_text'] as String? ?? 'Cavab yoxdur';
    final fileUrl = widget.submission['file_url'] as String?;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$studentName - Cavab', style: AppTextStyles.headlineSmall),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Text(answerText, style: AppTextStyles.bodyMedium),
          ),
          
          if (fileUrl != null && fileUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                // Should open fileUrl
              },
              icon: const Icon(Icons.download),
              label: const Text('Faylı yüklə / bax'),
            )
          ],
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Text('Qiymətləndirmə', style: AppTextStyles.titleMedium),
              const Spacer(),
              FilledButton.icon(
                onPressed: _isAIGrading ? null : _gradeWithAI,
                icon: _isAIGrading 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.auto_awesome, size: 16),
                label: const Text('AI Yoxlasın'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.info,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _scoreController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Bal (0-100)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _feedbackController,
                  decoration: InputDecoration(
                    labelText: 'Rəy / Feedback',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _isSaving ? null : _saveGrade,
              child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Yadda Saxla'),
            ),
          )
        ],
      ),
    );
  }
}
