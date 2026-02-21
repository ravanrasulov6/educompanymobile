import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/faq_model.dart';
import '../../providers/faq_provider.dart';

/// Manage FAQs screen — add/edit/delete + AI generation
class ManageFaqsScreen extends StatefulWidget {
  final String courseId;
  const ManageFaqsScreen({super.key, required this.courseId});

  @override
  State<ManageFaqsScreen> createState() => _ManageFaqsScreenState();
}

class _ManageFaqsScreenState extends State<ManageFaqsScreen> {
  List<Map<String, dynamic>> _sections = [];
  String? _selectedSectionId;
  String? _selectedSectionTitle;
  List<String> _lessonTitles = [];
  bool _isLoadingSections = true;

  @override
  void initState() {
    super.initState();
    _loadSections();
  }

  Future<void> _loadSections() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('course_sections')
          .select('id, title, lessons(title)')
          .eq('course_id', widget.courseId)
          .order('order_index');

      setState(() {
        _sections = (response as List).cast<Map<String, dynamic>>();
        _isLoadingSections = false;
      });
    } catch (e) {
      debugPrint('Error loading sections: $e');
      setState(() => _isLoadingSections = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ İdarəsi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoadingSections
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Section selector
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    value: _selectedSectionId,
                    decoration:
                        const InputDecoration(hintText: 'Bölmə seçin'),
                    items: _sections
                        .map((s) => DropdownMenuItem(
                              value: s['id'] as String,
                              child: Text(s['title'] as String),
                            ))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedSectionId = v;
                        final section =
                            _sections.firstWhere((s) => s['id'] == v);
                        _selectedSectionTitle = section['title'] as String;
                        _lessonTitles = (section['lessons'] as List?)
                                ?.map((l) => l['title'] as String)
                                .toList() ??
                            [];
                      });
                      if (v != null) {
                        Provider.of<FaqProvider>(context, listen: false)
                            .loadFaqs(v);
                      }
                    },
                  ),
                ),

                if (_selectedSectionId != null) ...[
                  // AI Generate button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Consumer<FaqProvider>(
                      builder: (_, provider, __) => SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: provider.isGenerating
                              ? null
                              : () => _generateWithAI(provider),
                          icon: provider.isGenerating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Icon(Icons.auto_awesome, size: 18),
                          label: Text(provider.isGenerating
                              ? 'AI yaradır...'
                              : '🤖 AI ilə FAQ Yarat'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // AI generated preview
                  Consumer<FaqProvider>(
                    builder: (_, provider, __) {
                      if (provider.aiGeneratedFaqs.isNotEmpty) {
                        return _buildAIPreview(provider);
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Existing FAQs
                  Expanded(
                    child: Consumer<FaqProvider>(
                      builder: (_, provider, __) {
                        if (provider.isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final faqs = provider.faqs;
                        if (faqs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.quiz_outlined,
                                    size: 48,
                                    color: AppColors.textSecondary
                                        .withValues(alpha: 0.3)),
                                const SizedBox(height: 12),
                                const Text('Bu bölmədə FAQ yoxdur'),
                                const SizedBox(height: 8),
                                const Text(
                                    'AI ilə yaradın və ya əl ilə əlavə edin',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: faqs.length,
                          itemBuilder: (_, i) =>
                              _buildFaqItem(faqs[i], provider),
                        );
                      },
                    ),
                  ),
                ] else
                  Expanded(
                    child: Center(
                      child: Text('Bölmə seçin',
                          style: AppTextStyles.bodyLarge),
                    ),
                  ),
              ],
            ),
      floatingActionButton: _selectedSectionId != null
          ? FloatingActionButton(
              onPressed: _addFaqManually,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildAIPreview(FaqProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 18, color: AppColors.info),
              const SizedBox(width: 8),
              Text('AI yaratdığı FAQ-lar (${provider.aiGeneratedFaqs.length})',
                  style: AppTextStyles.titleSmall),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  await provider.saveAIGeneratedFaqs(_selectedSectionId!);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ FAQ-lar yadda saxlanıldı!')),
                    );
                  }
                },
                child: const Text('Hamısını saxla'),
              ),
            ],
          ),
          const Divider(),
          ...provider.aiGeneratedFaqs.asMap().entries.map((entry) {
            final faq = entry.value;
            return ListTile(
              dense: true,
              title: Text(faq['question'] ?? '', maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () => provider.removeAIFaq(entry.key),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFaqItem(FaqModel faq, FaqProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(faq.question, style: AppTextStyles.bodyMedium, maxLines: 2,
            overflow: TextOverflow.ellipsis),
        subtitle: Text(faq.categoryLabel,
            style: AppTextStyles.labelSmall),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
          onPressed: () => provider.deleteFaq(faq.id),
        ),
      ),
    );
  }

  Future<void> _generateWithAI(FaqProvider provider) async {
    await provider.generateFaqsWithAI(
      sectionTitle: _selectedSectionTitle ?? '',
      lessonTitles: _lessonTitles,
      count: 15,
    );
  }

  void _addFaqManually() {
    final qController = TextEditingController();
    final aController = TextEditingController();
    String category = 'general';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Yeni FAQ', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 16),
              TextField(
                controller: qController,
                decoration: const InputDecoration(hintText: 'Sual'),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: aController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Cavab'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(hintText: 'Kateqoriya'),
                items: const [
                  DropdownMenuItem(value: 'general', child: Text('Ümumi')),
                  DropdownMenuItem(value: 'technical', child: Text('Texniki')),
                  DropdownMenuItem(value: 'practical', child: Text('Praktiki')),
                ],
                onChanged: (v) =>
                    setSheetState(() => category = v ?? 'general'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (qController.text.isNotEmpty &&
                        aController.text.isNotEmpty) {
                      final provider =
                          Provider.of<FaqProvider>(context, listen: false);
                      await provider.addFaq(
                        sectionId: _selectedSectionId!,
                        question: qController.text,
                        answer: aController.text,
                        category: category,
                      );
                      if (mounted) Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Əlavə et'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
