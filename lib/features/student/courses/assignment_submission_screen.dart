import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/widgets/entrance_animation.dart';

class AssignmentSubmissionScreen extends StatefulWidget {
  final String assignmentId;

  const AssignmentSubmissionScreen({
    super.key,
    required this.assignmentId,
  });

  @override
  State<AssignmentSubmissionScreen> createState() => _AssignmentSubmissionScreenState();
}

class _AssignmentSubmissionScreenState extends State<AssignmentSubmissionScreen> {
  final _supabase = Supabase.instance.client;
  final _answerController = TextEditingController();
  
  Map<String, dynamic>? _assignment;
  Map<String, dynamic>? _submission;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final assignmentRes = await _supabase
          .from('assignments')
          .select()
          .eq('id', widget.assignmentId)
          .single();
      _assignment = assignmentRes;

      final submissionRes = await _supabase
          .from('assignment_submissions')
          .select()
          .eq('assignment_id', widget.assignmentId)
          .eq('student_id', userId)
          .maybeSingle();
      
      _submission = submissionRes;
      if (_submission != null && _submission!['answer_text'] != null) {
        _answerController.text = _submission!['answer_text'];
      }
    } catch (e) {
      debugPrint('Error loading assignment: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _submitAnswer() async {
    final answerText = _answerController.text.trim();
    if (answerText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zəhmət olmasa cavabınızı daxil edin')),
      );
      return;
    }

    HapticService.medium();
    setState(() => _isSubmitting = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      if (_submission == null) {
        await _supabase.from('assignment_submissions').insert({
          'assignment_id': widget.assignmentId,
          'student_id': userId,
          'answer_text': answerText,
          'status': 'pending',
        });
      } else {
        await _supabase.from('assignment_submissions').update({
          'answer_text': answerText,
          'status': 'pending', 
          'ai_score': null,
          'teacher_score': null,
        }).eq('id', _submission!['id']);
      }

      if (mounted) {
        HapticService.success();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Cavabınız göndərildi. Yoxlanılmasını gözləyin.'),
            backgroundColor: AppColors.success,
          ),
        );
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xəta: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_assignment == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(title: const Text('Tapşırıq')),
        body: const Center(child: Text('Tapşırıq tapılmadı')),
      );
    }

    final isGraded = _submission?['status'] == 'graded' || _submission?['status'] == 'failed';
    final score = _submission?['teacher_score'] ?? _submission?['ai_score'];
    final feedback = _submission?['teacher_feedback'] ?? _submission?['ai_feedback'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: const Color(0xFFF8F9FA).withValues(alpha: 0.8),
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.chevron_left, color: AppColors.primary, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                _assignment!['title'],
                style: AppTextStyles.titleLarge.copyWith(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: Instructions
                  _buildSectionTitle(Icons.assignment_rounded, 'Müəllimin Təlimatları'),
                  const SizedBox(height: 12),
                  EntranceAnimation(
                    delay: const Duration(milliseconds: 100),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildInstructionItem(1, 'Sənəd yalnız PDF formatında qəbul edilir.'),
                          const Divider(height: 24, color: Color(0xFFF8FAFC)),
                          _buildInstructionItem(2, 'Hər bir həll mərhələsini ardıcıl və aydın şəkildə izah edin.'),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.event_busy_rounded, size: 18, color: Color(0xFFF43F5E)),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SON TARİX',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: const Color(0xFFF43F5E),
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      '25 May, 2024 • 23:59',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: const Color(0xFF0F172A),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section 2: Resources
                  _buildSectionTitle(Icons.folder_open_rounded, 'Resurslar'),
                  const SizedBox(height: 12),
                  EntranceAnimation(
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: _buildResourceItem(
                        'picture_as_pdf',
                        'Tapşırıq_vərəqi_v1.pdf',
                        '2.4 MB • PDF Sənədi',
                        Colors.red.shade50,
                        Colors.red.shade500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section 3: Submission Area
                  _buildSectionTitle(Icons.cloud_upload_rounded, 'Göndəriş sahəsi'),
                  const SizedBox(height: 12),
                  EntranceAnimation(
                    delay: const Duration(milliseconds: 300),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          style: BorderStyle.solid, // Custom dashed border would need a painter
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.upload_file_rounded, color: AppColors.primary, size: 32),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Fayl seçin',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: const Color(0xFF0F172A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cihazınızdan PDF və ya şəkil formatında faylı buraya yükləyin',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section 4: Comment Area
                  _buildSectionTitle(Icons.chat_bubble_outline_rounded, 'Şərhiniz'),
                  const SizedBox(height: 12),
                  EntranceAnimation(
                    delay: const Duration(milliseconds: 400),
                    child: TextField(
                      controller: _answerController,
                      maxLines: 4,
                      readOnly: isGraded,
                      style: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: 'Müəllim üçün qeydlərinizi bura daxil edin...',
                        hintStyle: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                  ),

                  if (isGraded) ...[
                    const SizedBox(height: 24),
                    _buildGradeCard(score, feedback),
                  ],

                  const SizedBox(height: 120), // Space for sticky footer
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA).withValues(alpha: 0.9),
          border: const Border(top: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting || isGraded ? null : _submitAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
                ),
                child: _isSubmitting 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Tapşırığı Təsdiqlə və Göndər', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(width: 8),
                        Icon(Icons.send_rounded, size: 20),
                      ],
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionItem(int index, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$index',
              style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF64748B), height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildResourceItem(String iconName, String name, String size, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.picture_as_pdf_rounded, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                ),
                Text(
                  size,
                  style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.download_rounded, size: 18, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeCard(dynamic score, dynamic feedback) {
    final isSuccess = score != null && score >= 60;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSuccess ? const Color(0xFFECFDF5) : const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSuccess ? const Color(0xFF10B981).withValues(alpha: 0.2) : const Color(0xFFF43F5E).withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(
            isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
            color: isSuccess ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            isSuccess ? 'Qəbul edildi' : 'Təkrar cəhd edin',
            style: AppTextStyles.titleLarge.copyWith(
              color: isSuccess ? const Color(0xFF065F46) : const Color(0xFF9F1239),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Nəticə: $score / 100',
            style: AppTextStyles.headlineSmall.copyWith(
              color: isSuccess ? const Color(0xFF059669) : const Color(0xFFE11D48),
            ),
          ),
          if (feedback != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              feedback.toString(),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF64748B)),
            ),
          ]
        ],
      ),
    );
  }
}
