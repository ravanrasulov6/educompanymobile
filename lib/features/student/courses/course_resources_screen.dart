import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/course_resource_model.dart';
import '../../../providers/resource_provider.dart';

/// Student course resources screen — buy/download materials
class CourseResourcesScreen extends StatefulWidget {
  final String courseId;
  const CourseResourcesScreen({super.key, required this.courseId});

  @override
  State<CourseResourcesScreen> createState() => _CourseResourcesScreenState();
}

class _CourseResourcesScreenState extends State<CourseResourcesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ResourceProvider>(context, listen: false)
          .loadCourseResources(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resurslar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ResourceProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.resources.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open_outlined,
                      size: 64,
                      color: AppColors.textSecondary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('Bu kursda resurs yoxdur',
                      style: AppTextStyles.bodyLarge),
                ],
              ),
            );
          }

          // Group by section
          final freeResources =
              provider.resources.where((r) => r.isFree).toList();
          final paidResources =
              provider.resources.where((r) => !r.isFree).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (freeResources.isNotEmpty) ...[
                _buildSectionHeader('Pulsuz Resurslar', Icons.lock_open,
                    AppColors.success),
                ...freeResources
                    .map((r) => _buildResourceCard(r, provider)),
                const SizedBox(height: 24),
              ],
              if (paidResources.isNotEmpty) ...[
                _buildSectionHeader(
                    'Premium Resurslar', Icons.star, AppColors.accent),
                ...paidResources
                    .map((r) => _buildResourceCard(r, provider)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(title, style: AppTextStyles.titleMedium.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildResourceCard(
      CourseResourceModel resource, ResourceProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Type icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getTypeColor(resource.resourceType)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(resource.typeLabel.split(' ')[0],
                    style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(resource.title, style: AppTextStyles.titleSmall),
                  if (resource.description != null)
                    Text(resource.description!,
                        style: AppTextStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    '${resource.downloadCount} yükləmə',
                    style: AppTextStyles.labelSmall,
                  ),
                ],
              ),
            ),

            // Action button
            _buildActionButton(resource, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      CourseResourceModel resource, ResourceProvider provider) {
    if (resource.isFree || resource.isPurchased) {
      return FilledButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Yüklənir...')),
          );
        },
        icon: const Icon(Icons.download, size: 18),
        label: const Text('Yüklə'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.success,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
    }

    return Column(
      children: [
        Text(
          '₼${resource.price.toStringAsFixed(2)}',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        FilledButton(
          onPressed: () => _purchaseResource(resource, provider),
          style: FilledButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          ),
          child: const Text('Satın al', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Future<void> _purchaseResource(
      CourseResourceModel resource, ResourceProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Satın al'),
        content: Text(
            '${resource.title} resursunu ₼${resource.price.toStringAsFixed(2)} qiymətə almaq istəyirsiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Ləğv et'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Satın al'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.purchaseResource(resource.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success
              ? '✅ Resurs satın alındı!'
              : '❌ Satın alma uğursuz oldu'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ));
      }
    }
  }

  Color _getTypeColor(ResourceType type) {
    switch (type) {
      case ResourceType.pdf:
        return AppColors.error;
      case ResourceType.template:
        return AppColors.info;
      case ResourceType.source_code:
        return AppColors.success;
      case ResourceType.asset:
        return AppColors.accent;
      case ResourceType.other:
        return AppColors.textSecondary;
    }
  }
}
