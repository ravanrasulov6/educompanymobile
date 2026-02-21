import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/teacher_course_provider.dart';

/// Manage lessons — add sections, lessons, upload videos, configure QA
class ManageLessonsScreen extends StatefulWidget {
  final String courseId;
  const ManageLessonsScreen({super.key, required this.courseId});

  @override
  State<ManageLessonsScreen> createState() => _ManageLessonsScreenState();
}

class _ManageLessonsScreenState extends State<ManageLessonsScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _sections = [];
  String _courseTitle = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load course title
      final course = await _supabase
          .from('courses')
          .select('title')
          .eq('id', widget.courseId)
          .single();
      _courseTitle = course['title'] as String? ?? '';

      // Load sections with lessons
      final response = await _supabase
          .from('course_sections')
          .select('id, title, order_index, lessons(id, title, duration, video_url, gumlet_asset_id, order_index)')
          .eq('course_id', widget.courseId)
          .order('order_index');

      _sections = (response as List).cast<Map<String, dynamic>>();
      // Sort lessons within each section
      for (var section in _sections) {
        final lessons = section['lessons'] as List? ?? [];
        lessons.sort((a, b) =>
            (a['order_index'] as int? ?? 0)
                .compareTo(b['order_index'] as int? ?? 0));
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_courseTitle.isNotEmpty ? _courseTitle : 'Dərsləri İdarə Et'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/teacher/courses');
            }
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sections.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sections.length,
                    itemBuilder: (_, i) => _buildSectionCard(i),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewSection,
        icon: const Icon(Icons.add),
        label: const Text('Bölmə əlavə et'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.video_library_outlined,
                size: 40, color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 20),
          Text('Hələ bölmə yoxdur', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text('Kursunuza bölmə və dərs əlavə edin',
              style: AppTextStyles.bodySmall),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _addNewSection,
            icon: const Icon(Icons.add),
            label: const Text('İlk bölmə yarat'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(int sectionIndex) {
    final section = _sections[sectionIndex];
    final lessons = (section['lessons'] as List?) ?? [];
    final sectionTitle = section['title'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.primary.withValues(alpha: 0.08),
                AppColors.primary.withValues(alpha: 0.02),
              ]),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text('${sectionIndex + 1}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sectionTitle, style: AppTextStyles.titleMedium),
                      Text('${lessons.length} dərs',
                          style: AppTextStyles.labelSmall),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: AppColors.error),
                  onPressed: () => _confirmDeleteSection(
                      section['id'] as String, sectionTitle),
                ),
              ],
            ),
          ),

          // Lessons
          if (lessons.isNotEmpty)
            ...lessons.asMap().entries.map((entry) {
              final lesson = entry.value as Map<String, dynamic>;
              final hasVideo = lesson['video_url'] != null &&
                  (lesson['video_url'] as String).isNotEmpty;

              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: hasVideo
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        hasVideo
                            ? Icons.play_circle_filled
                            : Icons.videocam_off_outlined,
                        size: 18,
                        color: hasVideo
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                    title: Text(lesson['title'] as String,
                        style: AppTextStyles.bodyMedium),
                    subtitle: Row(
                      children: [
                        Text(lesson['duration'] as String? ?? '0:00',
                            style: AppTextStyles.labelSmall),
                        if (hasVideo) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Video ✓',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 18),
                      onSelected: (v) {
                        switch (v) {
                          case 'upload':
                            _uploadVideo(
                              lesson['id'] as String,
                              lesson['title'] as String,
                            );
                            break;
                          case 'qa':
                            _configureQA(lesson['id'] as String);
                            break;
                          case 'delete':
                            _deleteLesson(lesson['id'] as String);
                            break;
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'upload',
                          child: Row(
                            children: [
                              Icon(
                                hasVideo
                                    ? Icons.replay_rounded
                                    : Icons.upload_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 10),
                              Text(hasVideo
                                  ? 'Videonu yenilə'
                                  : 'Video yüklə'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'qa',
                          child: Row(
                            children: [
                              Icon(Icons.tune, size: 18, color: AppColors.info),
                              SizedBox(width: 10),
                              Text('Sual limitləri'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline,
                                  size: 18, color: AppColors.error),
                              const SizedBox(width: 10),
                              Text('Sil',
                                  style:
                                      TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (entry.key < lessons.length - 1)
                    Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Colors.grey.withValues(alpha: 0.1)),
                ],
              );
            }),

          // Add lesson button
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextButton.icon(
              onPressed: () =>
                  _addLesson(section['id'] as String, lessons.length),
              icon: const Icon(Icons.add, size: 16),
              label:
                  const Text('Dərs əlavə et', style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadVideo(String lessonId, String title) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final bytes = result.files.single.bytes!;
      final fileName = result.files.single.name;
      if (!mounted) return;

      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text('Video yüklənir...', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              Text(title, style: AppTextStyles.bodySmall),
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Text(fileName, style: AppTextStyles.labelSmall),
            ],
          ),
        ),
      );

      bool success = false;
      try {
        final path = 'videos/${widget.courseId}/${DateTime.now().millisecondsSinceEpoch}_$fileName';
        await _supabase.storage
            .from('courses')
            .uploadBinary(path, Uint8List.fromList(bytes));
        final videoUrl = _supabase.storage.from('courses').getPublicUrl(path);
        await _supabase
            .from('lessons')
            .update({'video_url': videoUrl}).eq('id', lessonId);
        success = true;
      } catch (e) {
        debugPrint('Video upload error: $e');
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              success ? '✅ Video uğurla yükləndi!' : '❌ Yükləmə uğursuz oldu'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ));
        if (success) await _loadData();
      }
    }
  }

  void _configureQA(String lessonId) {
    int aiLimit = 30;
    int teacherLimit = 3;

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Sual Limitləri', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 8),
              Text('Tələbələrin bu dərsdə soruşa biləcəyi sual sayını təyin edin',
                  style: AppTextStyles.bodySmall),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(Icons.smart_toy, size: 20, color: AppColors.info),
                  const SizedBox(width: 8),
                  Text('AI Sual Limiti: ', style: AppTextStyles.bodyMedium),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('$aiLimit',
                        style: const TextStyle(
                            color: AppColors.info,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              Slider(
                value: aiLimit.toDouble(),
                min: 0,
                max: 50,
                divisions: 50,
                activeColor: AppColors.info,
                onChanged: (v) => setSheetState(() => aiLimit = v.toInt()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person, size: 20, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Text('Müəllimə Sual Limiti: ',
                      style: AppTextStyles.bodyMedium),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('$teacherLimit',
                        style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              Slider(
                value: teacherLimit.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                activeColor: AppColors.accent,
                onChanged: (v) =>
                    setSheetState(() => teacherLimit = v.toInt()),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () async {
                    final provider = Provider.of<TeacherCourseProvider>(
                        context, listen: false);
                    await provider.updateQAConfig(
                      lessonId: lessonId,
                      aiQuestionLimit: aiLimit,
                      teacherQuestionLimit: teacherLimit,
                    );
                    if (mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('✅ Limitlər yadda saxlanıldı')),
                      );
                    }
                  },
                  child: const Text('Yadda saxla'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addNewSection() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Yeni Bölmə'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Bölmə adı',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autofocus: true,
          onSubmitted: (_) => _submitSection(controller, ctx),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Ləğv et')),
          FilledButton(
            onPressed: () => _submitSection(controller, ctx),
            child: const Text('Əlavə et'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitSection(
      TextEditingController controller, BuildContext ctx) async {
    if (controller.text.trim().isEmpty) return;
    final provider =
        Provider.of<TeacherCourseProvider>(context, listen: false);
    await provider.addSection(
      courseId: widget.courseId,
      title: controller.text.trim(),
      orderIndex: _sections.length + 1,
    );
    if (mounted) {
      Navigator.pop(ctx);
      await _loadData();
    }
  }

  void _addLesson(String sectionId, int lessonCount) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Yeni Dərs'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Dərs adı',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autofocus: true,
          onSubmitted: (_) =>
              _submitLesson(controller, ctx, sectionId, lessonCount),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Ləğv et')),
          FilledButton(
            onPressed: () =>
                _submitLesson(controller, ctx, sectionId, lessonCount),
            child: const Text('Əlavə et'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitLesson(TextEditingController controller,
      BuildContext ctx, String sectionId, int lessonCount) async {
    if (controller.text.trim().isEmpty) return;
    final provider =
        Provider.of<TeacherCourseProvider>(context, listen: false);
    await provider.addLesson(
      sectionId: sectionId,
      title: controller.text.trim(),
      orderIndex: lessonCount + 1,
    );
    if (mounted) {
      Navigator.pop(ctx);
      await _loadData();
    }
  }

  Future<void> _deleteLesson(String lessonId) async {
    final provider =
        Provider.of<TeacherCourseProvider>(context, listen: false);
    await provider.deleteLesson(lessonId);
    await _loadData();
  }

  void _confirmDeleteSection(String sectionId, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Bölməni silmək istəyirsiniz?'),
        content:
            Text('"$title" bölməsi və bütün dərsləri silinəcək.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Ləğv et')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = Provider.of<TeacherCourseProvider>(context,
                  listen: false);
              await provider.deleteSection(sectionId);
              await _loadData();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
