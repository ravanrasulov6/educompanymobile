import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/faq_model.dart';
import '../../../providers/faq_provider.dart';

/// Student FAQ screen — per-section FAQs with search and categories
class LessonFaqScreen extends StatefulWidget {
  final String courseId;
  final List<Map<String, dynamic>> sections;

  const LessonFaqScreen({
    super.key,
    required this.courseId,
    required this.sections,
  });

  @override
  State<LessonFaqScreen> createState() => _LessonFaqScreenState();
}

class _LessonFaqScreenState extends State<LessonFaqScreen> {
  String? _selectedSectionId;
  String _selectedSectionTitle = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Section tabs
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: widget.sections.length,
              itemBuilder: (_, i) {
                final section = widget.sections[i];
                final isSelected = section['id'] == _selectedSectionId;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(section['title'] as String),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedSectionId = section['id'] as String;
                        _selectedSectionTitle = section['title'] as String;
                      });
                      Provider.of<FaqProvider>(context, listen: false)
                          .loadFaqs(section['id'] as String);
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: isSelected ? FontWeight.w600 : null,
                    ),
                  ),
                );
              },
            ),
          ),

          if (_selectedSectionId != null) ...[
            // Search + category filter
            Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer<FaqProvider>(
                builder: (_, provider, __) => Column(
                  children: [
                    TextField(
                      onChanged: provider.setSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'FAQ-larda axtar...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildCategoryChip(provider, 'all', 'Hamısı'),
                        const SizedBox(width: 6),
                        _buildCategoryChip(provider, 'general', 'Ümumi'),
                        const SizedBox(width: 6),
                        _buildCategoryChip(
                            provider, 'technical', 'Texniki'),
                        const SizedBox(width: 6),
                        _buildCategoryChip(
                            provider, 'practical', 'Praktiki'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // FAQ list
            Expanded(
              child: Consumer<FaqProvider>(
                builder: (_, provider, __) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final faqs = provider.faqs;

                  if (faqs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.quiz_outlined,
                              size: 56,
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.3)),
                          const SizedBox(height: 12),
                          Text('FAQ tapılmadı',
                              style: AppTextStyles.bodyLarge),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: faqs.length,
                    itemBuilder: (_, i) => _buildFaqCard(faqs[i], provider),
                  );
                },
              ),
            ),
          ] else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.library_books_outlined,
                        size: 64,
                        color:
                            AppColors.textSecondary.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Text('Bölmə seçin', style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 8),
                    Text('FAQ-lara baxmaq üçün mövzu seçin',
                        style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
      FaqProvider provider, String category, String label) {
    final isSelected = provider.selectedCategory == category;
    return GestureDetector(
      onTap: () => provider.setCategory(category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFaqCard(FaqModel faq, FaqProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding:
            const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              const Icon(Icons.help_outline, size: 18, color: AppColors.primary),
        ),
        title: Text(faq.question, style: AppTextStyles.bodyMedium),
        subtitle: Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getCategoryColor(faq.category).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            faq.categoryLabel,
            style: TextStyle(
              fontSize: 10,
              color: _getCategoryColor(faq.category),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        children: [
          Text(faq.answer, style: AppTextStyles.bodyMedium.copyWith(height: 1.5)),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () => provider.markHelpful(faq.id),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.thumb_up_outlined,
                          size: 14, color: AppColors.success),
                      const SizedBox(width: 6),
                      Text(
                        'Faydalı (${faq.helpfulCount})',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'general':
        return AppColors.info;
      case 'technical':
        return AppColors.warning;
      case 'practical':
        return AppColors.success;
      default:
        return AppColors.info;
    }
  }
}
