import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/premium_button.dart';
import '../../core/services/openai_service.dart';
import '../../providers/teacher_course_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 4-step course creation: Info → Price → Sections/Lessons/Materials → Summary
class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController(text: '0');

  int _currentStep = 0;
  bool _isFree = true;
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  List<Map<String, String>> _categories = [];
  bool _isCreating = false;
  bool _isGeneratingDesc = false;

  // Thumbnail
  String? _thumbnailName;
  Uint8List? _thumbnailBytes;

  final List<_SectionData> _sections = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final provider = Provider.of<TeacherCourseProvider>(context, listen: false);
    final cats = await provider.getCategories();
    if (mounted) setState(() => _categories = cats);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Kurs Yarat'),
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
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primary,
              ),
        ),
        child: Stepper(
          currentStep: _currentStep,
          type: StepperType.vertical,
          physics: const ClampingScrollPhysics(),
          onStepContinue: _onStepContinue,
          onStepCancel:
              _currentStep > 0 ? () => setState(() => _currentStep--) : null,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Expanded(
                    child: PremiumButton(
                      label: _currentStep == 3 ? 'Kursu Yarat' : 'Növbəti',
                      onPressed: details.onStepContinue!,
                      isGradient: true,
                      isLoading: _isCreating,
                      icon: _currentStep == 3
                          ? Icons.check_circle
                          : Icons.arrow_forward,
                      height: 48,
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 100,
                      child: PremiumButton(
                        label: 'Geri',
                        onPressed: details.onStepCancel!,
                        isOutlined: true,
                        height: 48,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Kurs Məlumatları'),
              subtitle: const Text('Başlıq, təsvir, kateqoriya, şəkil'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: _buildStepInfo(),
            ),
            Step(
              title: const Text('Qiymət'),
              subtitle: const Text('Pulsuz və ya pullu'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: _buildStepPrice(),
            ),
            Step(
              title: const Text('Bölmələr, Dərslər & Materiallar'),
              subtitle: const Text('Video, fayl, struktur'),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              content: _buildStepContent(),
            ),
            Step(
              title: const Text('Yekun'),
              subtitle: const Text('Yaratmağa hazır'),
              isActive: _currentStep >= 3,
              state: StepState.indexed,
              content: _buildStepSummary(),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 1: Course Info + Thumbnail
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStepInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kurs Başlığı', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'Məsələn: Flutter İnkişafı Masterklas',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Text('Təsvir', style: AppTextStyles.labelLarge),
            const Spacer(),
            _isGeneratingDesc
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : TextButton.icon(
                    onPressed: _generateDescriptionWithAI,
                    icon: const Icon(Icons.auto_awesome,
                        size: 16, color: AppColors.primary),
                    label: const Text('AI ilə yaz',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Kurs haqqında ətraflı təsvir...',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 20),
        Text('Kateqoriya', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategoryId,
          decoration: InputDecoration(
            hintText: 'Kateqoriya seçin',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: _categories
              .map((c) => DropdownMenuItem(
                    value: c['id'],
                    child: Text(c['name']!),
                  ))
              .toList(),
          onChanged: (v) {
            final cat = _categories.firstWhere((c) => c['id'] == v,
                orElse: () => <String, String>{'id': '', 'name': ''});
            setState(() {
              _selectedCategoryId = v;
              _selectedCategoryName = cat['name'];
            });
          },
        ),
        const SizedBox(height: 20),

        // Thumbnail
        Text('Kurs Şəkli', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickThumbnail,
          child: Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _thumbnailBytes != null
                    ? AppColors.success
                    : AppColors.primary.withValues(alpha: 0.2),
              ),
              color: _thumbnailBytes != null
                  ? AppColors.success.withValues(alpha: 0.05)
                  : AppColors.primary.withValues(alpha: 0.02),
            ),
            child: _thumbnailBytes != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.success, size: 24),
                      const SizedBox(width: 8),
                      Text(_thumbnailName ?? 'Seçildi',
                          style: const TextStyle(color: AppColors.success)),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => setState(() {
                          _thumbnailBytes = null;
                          _thumbnailName = null;
                        }),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 28,
                          color: AppColors.primary.withValues(alpha: 0.4)),
                      const SizedBox(height: 6),
                      Text('Şəkil seçin',
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 2: Price Only
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStepPrice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.primary.withValues(alpha: 0.04),
          ),
          child: SwitchListTile(
            title: const Text('Pulsuz Kurs',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              _isFree
                  ? 'Bu kurs pulsuz olacaq'
                  : 'Qiymət təyin edin',
              style: AppTextStyles.bodySmall,
            ),
            value: _isFree,
            onChanged: (v) => setState(() => _isFree = v),
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        if (!_isFree) ...[
          const SizedBox(height: 16),
          Text('Qiymət (AZN)', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '29.99',
              prefixText: '₼ ',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 3: Sections + Lessons + Videos + Materials
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStepContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_sections.isEmpty)
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
                Icon(Icons.layers_outlined,
                    size: 40,
                    color: AppColors.primary.withValues(alpha: 0.4)),
                const SizedBox(height: 12),
                Text('Hələ bölmə yoxdur',
                    style: AppTextStyles.titleMedium),
                const SizedBox(height: 4),
                Text(
                    'Bölmə yaradın, dərslər əlavə edin, video və material yükləyin',
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center),
              ],
            ),
          ),

        // Sections
        ..._sections.asMap().entries.map((entry) {
          final i = entry.key;
          final section = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.15)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text('${i + 1}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(section.title,
                            style: AppTextStyles.titleMedium),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () =>
                            setState(() => _sections.removeAt(i)),
                        color: AppColors.error,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),

                  // Lessons in this section
                  if (section.lessons.isNotEmpty) ...[
                    const Divider(height: 16),
                    ...section.lessons.asMap().entries.map((le) {
                      final lesson = le.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.withValues(alpha: 0.04),
                          border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Lesson title row
                            Row(
                              children: [
                                Icon(Icons.play_circle_outline,
                                    size: 18,
                                    color: AppColors.primary
                                        .withValues(alpha: 0.6)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(lesson.title,
                                      style: AppTextStyles.bodyMedium
                                          .copyWith(
                                              fontWeight: FontWeight.w600)),
                                ),
                                IconButton(
                                  icon:
                                      const Icon(Icons.close, size: 14),
                                  onPressed: () => setState(
                                      () => section.lessons.removeAt(le.key)),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),

                            // Video attachment
                            if (lesson.videoName != null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 26, top: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.videocam,
                                        size: 14, color: AppColors.success),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(lesson.videoName!,
                                          style: AppTextStyles.labelSmall
                                              .copyWith(
                                                  color: AppColors.success),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                    GestureDetector(
                                      onTap: () => setState(() {
                                        lesson.videoName = null;
                                        lesson.videoBytes = null;
                                      }),
                                      child: const Icon(Icons.close,
                                          size: 12, color: AppColors.error),
                                    ),
                                  ],
                                ),
                              ),

                            // Material attachments
                            ...lesson.materials.asMap().entries.map((me) {
                              final mat = me.value;
                              return Padding(
                                padding:
                                    const EdgeInsets.only(left: 26, top: 3),
                                child: Row(
                                  children: [
                                    Icon(_getFileIcon(mat.extension),
                                        size: 14, color: AppColors.info),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(mat.name,
                                          style: AppTextStyles.labelSmall
                                              .copyWith(
                                                  color: AppColors.info),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                    Text(_formatBytes(mat.size),
                                        style: TextStyle(
                                            fontSize: 9,
                                            color: AppColors.textSecondary)),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () => setState(() =>
                                          lesson.materials.removeAt(me.key)),
                                      child: const Icon(Icons.close,
                                          size: 12, color: AppColors.error),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            // Action buttons for lesson
                            Padding(
                              padding: const EdgeInsets.only(left: 22, top: 6),
                              child: Wrap(
                                spacing: 6,
                                children: [
                                  _miniButton(
                                    icon: lesson.videoName != null
                                        ? Icons.replay
                                        : Icons.videocam_outlined,
                                    label: lesson.videoName != null
                                        ? 'Dəyiş'
                                        : 'Video',
                                    color: AppColors.accent,
                                    onTap: () =>
                                        _pickLessonVideo(i, le.key),
                                  ),
                                  _miniButton(
                                    icon: Icons.attach_file,
                                    label: 'Material',
                                    color: AppColors.info,
                                    onTap: () =>
                                        _pickLessonMaterial(i, le.key),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],

                  // Add lesson button
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: TextButton.icon(
                      onPressed: () => _addLesson(i),
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text('Dərs əlavə et',
                          style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addSection,
            icon: const Icon(Icons.add_box_outlined),
            label: const Text('Yeni bölmə əlavə et'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 4: Summary
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStepSummary() {
    int totalLessons =
        _sections.fold<int>(0, (sum, s) => sum + s.lessons.length);
    int totalVideos = _sections.fold<int>(
        0,
        (sum, s) =>
            sum + s.lessons.where((l) => l.videoBytes != null).length);
    int totalMaterials = _sections.fold<int>(
        0, (sum, s) => sum + s.lessons.fold<int>(0, (s2, l) => s2 + l.materials.length));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.primary.withValues(alpha: 0.03),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kurs Xülasəsi', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 16),
          _infoRow(Icons.title, 'Başlıq', _titleController.text),
          _infoRow(Icons.description, 'Təsvir',
              _descController.text.isNotEmpty ? '✓' : '—'),
          _infoRow(Icons.category, 'Kateqoriya',
              _selectedCategoryName ?? '—'),
          _infoRow(Icons.monetization_on, 'Qiymət',
              _isFree ? 'Pulsuz' : '₼${_priceController.text}'),
          _infoRow(Icons.photo, 'Şəkil',
              _thumbnailBytes != null ? '✓' : '—'),
          _infoRow(Icons.layers, 'Bölmələr', '${_sections.length}'),
          _infoRow(Icons.play_lesson, 'Dərslər', '$totalLessons'),
          _infoRow(Icons.videocam, 'Videolar', '$totalVideos'),
          _infoRow(Icons.attach_file, 'Materiallar', '$totalMaterials'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon,
              size: 16, color: AppColors.primary.withValues(alpha: 0.5)),
          const SizedBox(width: 10),
          SizedBox(
              width: 85,
              child: Text(label, style: AppTextStyles.bodySmall)),
          Expanded(
            child: Text(value,
                style: AppTextStyles.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // FILE PICKERS
  // ═══════════════════════════════════════════════════════════════
  Future<void> _pickThumbnail() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
      _thumbnailBytes = result.files.single.bytes!;
        _thumbnailName = result.files.single.name;
      });
    }
  }

  Future<void> _pickLessonVideo(int sectionIdx, int lessonIdx) async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.video, withData: true);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _sections[sectionIdx].lessons[lessonIdx].videoBytes =
            result.files.single.bytes!.toList();
        _sections[sectionIdx].lessons[lessonIdx].videoName =
            result.files.single.name;
      });
    }
  }

  Future<void> _pickLessonMaterial(int sectionIdx, int lessonIdx) async {
    final result =
        await FilePicker.platform.pickFiles(allowMultiple: true, withData: true);
    if (result != null) {
      for (final file in result.files) {
        if (file.bytes != null) {
          setState(() {
            _sections[sectionIdx].lessons[lessonIdx].materials.add(
              _MaterialFile(
                name: file.name,
                bytes: file.bytes!.toList(),
                size: file.size,
                extension: file.extension ?? '',
              ),
            );
          });
        }
      }
    }
  }

  IconData _getFileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'mp4':
      case 'mov':
        return Icons.videocam;
      case 'jpg':
      case 'png':
      case 'webp':
        return Icons.image;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      case 'dart':
      case 'js':
      case 'py':
        return Icons.code;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // ═══════════════════════════════════════════════════════════════
  // AI DESCRIPTION
  // ═══════════════════════════════════════════════════════════════
  Future<void> _generateDescriptionWithAI() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Əvvəlcə kurs başlığını yazın')),
      );
      return;
    }

    setState(() => _isGeneratingDesc = true);
    final description = await OpenAIService.instance.generateCourseDescription(
      courseTitle: title,
      category: _selectedCategoryName,
      sectionTitles: _sections.map((s) => s.title).toList(),
    );

    if (description.isNotEmpty && mounted) {
      _descController.text = description;
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI hazırda əlçatan deyil, əl ilə yazın')),
      );
    }
    if (mounted) setState(() => _isGeneratingDesc = false);
  }

  // ═══════════════════════════════════════════════════════════════
  // SECTION & LESSON DIALOGS
  // ═══════════════════════════════════════════════════════════════
  void _addSection() {
    final c = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Yeni Bölmə'),
        content: TextField(
          controller: c,
          decoration: InputDecoration(
            hintText: 'Bölmə adı',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autofocus: true,
          onSubmitted: (_) {
            if (c.text.isNotEmpty) {
              setState(() => _sections.add(_SectionData(title: c.text)));
              Navigator.pop(ctx);
            }
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Ləğv et')),
          FilledButton(
            onPressed: () {
              if (c.text.isNotEmpty) {
                setState(() => _sections.add(_SectionData(title: c.text)));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Əlavə et'),
          ),
        ],
      ),
    );
  }

  void _addLesson(int sectionIndex) {
    final c = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Yeni Dərs'),
        content: TextField(
          controller: c,
          decoration: InputDecoration(
            hintText: 'Dərs adı',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autofocus: true,
          onSubmitted: (_) {
            if (c.text.isNotEmpty) {
              setState(() => _sections[sectionIndex].lessons
                  .add(_LessonData(title: c.text)));
              Navigator.pop(ctx);
            }
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Ləğv et')),
          FilledButton(
            onPressed: () {
              if (c.text.isNotEmpty) {
                setState(() => _sections[sectionIndex].lessons
                    .add(_LessonData(title: c.text)));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Əlavə et'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SUBMIT
  // ═══════════════════════════════════════════════════════════════
  Future<void> _onStepContinue() async {
    if (_currentStep < 3) {
      if (_currentStep == 0 && _titleController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kurs başlığını daxil edin')),
        );
        return;
      }
      setState(() => _currentStep++);
      return;
    }

    setState(() => _isCreating = true);
    final provider =
        Provider.of<TeacherCourseProvider>(context, listen: false);
    final supabase = Supabase.instance.client;

    // Upload thumbnail
    String? thumbnailUrl;
    if (_thumbnailBytes != null && _thumbnailName != null) {
      try {
        final path =
            'thumbnails/${DateTime.now().millisecondsSinceEpoch}_$_thumbnailName';
        await supabase.storage
            .from('courses')
            .uploadBinary(path, _thumbnailBytes!);
        thumbnailUrl = supabase.storage.from('courses').getPublicUrl(path);
      } catch (e) {
        debugPrint('Thumbnail upload: $e');
      }
    }

    // Create course
    final courseId = await provider.createCourse(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      categoryId: _selectedCategoryId,
      price: _isFree ? 0.0 : double.tryParse(_priceController.text) ?? 0.0,
      isFree: _isFree,
      thumbnailUrl: thumbnailUrl,
    );

    if (courseId != null && mounted) {
      // Create sections, lessons, upload videos & materials
      for (int i = 0; i < _sections.length; i++) {
        final sectionId = await provider.addSection(
          courseId: courseId,
          title: _sections[i].title,
          orderIndex: i + 1,
        );
        if (sectionId != null) {
          for (int j = 0; j < _sections[i].lessons.length; j++) {
            final lesson = _sections[i].lessons[j];
            final lessonId = await provider.addLesson(
              sectionId: sectionId,
              title: lesson.title,
              orderIndex: j + 1,
            );

            if (lessonId != null) {
              // Upload video if attached
              if (lesson.videoBytes != null && lesson.videoName != null) {
                try {
                  final vPath =
                      'videos/$courseId/${lesson.videoName}';
                  await supabase.storage
                      .from('courses')
                      .uploadBinary(vPath, Uint8List.fromList(lesson.videoBytes!));
                  final videoUrl =
                      supabase.storage.from('courses').getPublicUrl(vPath);
                  await supabase
                      .from('lessons')
                      .update({'video_url': videoUrl}).eq('id', lessonId);
                } catch (e) {
                  debugPrint('Video upload: $e');
                }
              }

              // Upload materials
              for (final mat in lesson.materials) {
                try {
                  final mPath =
                      'materials/$courseId/$lessonId/${mat.name}';
                  await supabase.storage
                      .from('courses')
                      .uploadBinary(mPath, Uint8List.fromList(mat.bytes));
                  final fileUrl =
                      supabase.storage.from('courses').getPublicUrl(mPath);
                  await supabase.from('course_resources').insert({
                    'course_id': courseId,
                    'section_id': sectionId,
                    'title': mat.name,
                    'resource_type': _getResourceType(mat.extension),
                    'file_url': fileUrl,
                    'is_free': true,
                  });
                } catch (e) {
                  debugPrint('Material upload: $e');
                }
              }
            }
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Kurs uğurla yaradıldı!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/teacher/courses');
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('❌ Xəta: ${provider.error ?? "Kurs yaradıla bilmədi"}'),
          backgroundColor: AppColors.error,
        ),
      );
    }

    if (mounted) setState(() => _isCreating = false);
  }

  String _getResourceType(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return 'pdf';
      case 'dart':
      case 'js':
      case 'zip':
        return 'source_code';
      case 'png':
      case 'jpg':
      case 'svg':
        return 'asset';
      default:
        return 'other';
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════
class _SectionData {
  final String title;
  final List<_LessonData> lessons;
  _SectionData({required this.title}) : lessons = [];
}

class _LessonData {
  final String title;
  List<int>? videoBytes;
  String? videoName;
  final List<_MaterialFile> materials;
  _LessonData({required this.title}) : materials = [];
}

class _MaterialFile {
  final String name;
  final List<int> bytes;
  final int size;
  final String extension;
  _MaterialFile({
    required this.name,
    required this.bytes,
    required this.size,
    required this.extension,
  });
}
