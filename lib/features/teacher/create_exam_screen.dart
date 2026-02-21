import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/premium_button.dart';
import '../../core/widgets/markdown_editor_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ai_exam_generator_sheet.dart';

/// Dynamic create exam screen with Supabase data
class CreateExamScreen extends StatefulWidget {
  const CreateExamScreen({super.key});

  @override
  State<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  final _supabase = Supabase.instance.client;
  final _titleController = TextEditingController();
  final _durationController = TextEditingController(text: '30');
  final _passingController = TextEditingController(text: '60');

  List<Map<String, dynamic>> _courses = [];
  String? _selectedCourseId;
  String _selectedCategory = 'course_evaluation';
  bool _isLoading = true;
  bool _isSubmitting = false;

  String _selectedExamType = 'standard';
  String _selectedPenaltyRule = 'none';

  // Questions
  final List<_ExamQuestion> _questions = [];

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
    _durationController.dispose();
    _passingController.dispose();
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
          Text('Yeni İmtahan', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 24),

          Text('Başlıq', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'İmtahan başlığı',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),

          Text('İmtahan Kateqoriyası', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'course_evaluation',
                label: Text('Kurs İmtahanı'),
              ),
              ButtonSegment(
                value: 'general_mock',
                label: Text('Ümumi Sınaq'),
              ),
            ],
            selected: {_selectedCategory},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _selectedCategory = newSelection.first;
                if (_selectedCategory == 'general_mock') {
                  _selectedCourseId = null;
                }
              });
            },
            showSelectedIcon: true,
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.primary.withValues(alpha: 0.1),
              selectedForegroundColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),

          if (_selectedCategory == 'course_evaluation') ...[
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
          ],

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Müddət (dəq)', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '30',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Keçid balı (%)', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passingController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '60',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text('İmtahan Tipi', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            value: _selectedExamType,
            items: const [
              DropdownMenuItem(value: 'standard', child: Text('Sadə Test')),
              DropdownMenuItem(value: 'block', child: Text('Blok İmtahanı')),
              DropdownMenuItem(value: 'admission', child: Text('Buraxılış İmtahanı')),
              DropdownMenuItem(value: 'contest', child: Text('Müsabiqə')),
            ],
            onChanged: (v) => setState(() => _selectedExamType = v!),
          ),
          const SizedBox(height: 20),

          Text('Səhv Düzü Aparır (Penalty Rule)', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            value: _selectedPenaltyRule,
            items: const [
              DropdownMenuItem(value: 'none', child: Text('Silinmə yoxdur')),
              DropdownMenuItem(value: 'four_for_one', child: Text('4 səhv 1 düzü silir')),
              DropdownMenuItem(value: 'three_for_one', child: Text('3 səhv 1 düzü silir')),
              DropdownMenuItem(value: 'two_for_one', child: Text('2 səhv 1 düzü silir')),
            ],
            onChanged: (v) => setState(() => _selectedPenaltyRule = v!),
          ),
          const SizedBox(height: 28),

          Row(
            children: [
              Text('Suallar (${_questions.length})',
                  style: AppTextStyles.headlineSmall),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: AIExamGeneratorSheet(
                        examType: _selectedExamType,
                        penaltyRule: _selectedPenaltyRule,
                        onQuestionsGenerated: (newQs) {
                          setState(() {
                            for (var q in newQs) {
                              _questions.add(_ExamQuestion(
                                question: q['question'],
                                options: List<String>.from(q['options']),
                                correctIndex: q['correctIndex'],
                              ));
                            }
                          });
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.auto_awesome, size: 18, color: AppColors.info),
                label: const Text('AI', style: TextStyle(color: AppColors.info)),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.info.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _addQuestion,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Sual əlavə et'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_questions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  Icon(Icons.quiz_outlined,
                      size: 36,
                      color:
                          AppColors.primary.withValues(alpha: 0.3)),
                  const SizedBox(height: 8),
                  Text('Hələ sual yoxdur',
                      style: AppTextStyles.bodySmall),
                ],
              ),
            ),

          ..._questions.asMap().entries.map((entry) {
            final i = entry.key;
            final q = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.12)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Center(
                            child: Text('${i + 1}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MarkdownBody(
                            data: q.question,
                            styleSheet: MarkdownStyleSheet(
                              p: AppTextStyles.bodyMedium,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              size: 18, color: AppColors.error),
                          onPressed: () =>
                              setState(() => _questions.removeAt(i)),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ...q.options.asMap().entries.map((oe) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 34, top: 2),
                        child: Row(
                          children: [
                            Icon(
                              oe.key == q.correctIndex
                                  ? Icons.check_circle
                                  : Icons.radio_button_off,
                              size: 14,
                              color: oe.key == q.correctIndex
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: MarkdownBody(
                                data: oe.value,
                                styleSheet: MarkdownStyleSheet(
                                  p: AppTextStyles.bodySmall.copyWith(
                                    color: oe.key == q.correctIndex
                                        ? AppColors.success
                                        : null,
                                    fontWeight: oe.key == q.correctIndex
                                        ? FontWeight.w600
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 24),
          PremiumButton(
            label: 'İmtahan Yarat',
            isGradient: true,
            icon: Icons.quiz_rounded,
            isLoading: _isSubmitting,
            height: 52,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  void _addQuestion() {
    final qController = TextEditingController();
    final optControllers = List.generate(4, (_) => TextEditingController());
    int correctIndex = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text('Yeni Sual', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 16),
              MarkdownEditorField(
                hintText: 'Sual mətni...',
                minHeight: 120,
                onChanged: (val) {
                  qController.text = val;
                },
              ),
              const SizedBox(height: 12),
              ...List.generate(4, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Radio<int>(
                        value: i,
                        groupValue: correctIndex,
                        onChanged: (v) =>
                            setSheetState(() => correctIndex = v!),
                        activeColor: AppColors.success,
                        visualDensity: VisualDensity.compact,
                      ),
                      Expanded(
                        child: MarkdownEditorField(
                          hintText: 'Variant ${String.fromCharCode(65 + i)}',
                          minHeight: 80,
                          onChanged: (val) {
                            optControllers[i].text = val;
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (qController.text.isNotEmpty &&
                        optControllers.every((c) => c.text.isNotEmpty)) {
                      setState(() {
                        _questions.add(_ExamQuestion(
                          question: qController.text,
                          options:
                              optControllers.map((c) => c.text).toList(),
                          correctIndex: correctIndex,
                        ));
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Əlavə et'),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty || _questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başlıq və ən az 1 sual daxil edin')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final examData = {
        'title': _titleController.text.trim(),
        'category': _selectedCategory,
        'course_id': _selectedCategory == 'course_evaluation' ? _selectedCourseId : null,
        'duration_minutes': int.tryParse(_durationController.text) ?? 30,
        'passing_score': int.tryParse(_passingController.text) ?? 60,
        'instructor_id': _supabase.auth.currentUser?.id,
        'type': _selectedExamType,
        'type': _selectedExamType,
        'penalty_rule': _selectedPenaltyRule,
      };

      final response = await _supabase.from('exams').insert(examData).select('id').single();
      final examId = response['id'];

      if (_questions.isNotEmpty) {
        final questionsData = _questions.map((q) => {
          'exam_id': examId,
          'question': q.question,
          'options': q.options,
          'correct_index': q.correctIndex,
        }).toList();

        await _supabase.from('exam_questions').insert(questionsData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ İmtahan yaradıldı!'),
            backgroundColor: AppColors.success,
          ),
        );
        _titleController.clear();
        setState(() {
          _selectedCourseId = null;
          _questions.clear();
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

class _ExamQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  _ExamQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}
