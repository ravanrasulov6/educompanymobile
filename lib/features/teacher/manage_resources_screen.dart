import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/course_resource_model.dart';
import '../../providers/resource_provider.dart';

/// Manage resources screen — add/delete paid/free materials
class ManageResourcesScreen extends StatefulWidget {
  final String courseId;
  const ManageResourcesScreen({super.key, required this.courseId});

  @override
  State<ManageResourcesScreen> createState() => _ManageResourcesScreenState();
}

class _ManageResourcesScreenState extends State<ManageResourcesScreen> {
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
                  Text('Resurs yoxdur', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 8),
                  Text('PDF, şablon, kod faylları əlavə edin',
                      style: AppTextStyles.bodySmall),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.resources.length,
            itemBuilder: (_, i) =>
                _buildResourceCard(provider.resources[i], provider),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addResource,
        icon: const Icon(Icons.add),
        label: const Text('Resurs əlavə et'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildResourceCard(
      CourseResourceModel resource, ResourceProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _getTypeColor(resource.resourceType).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(resource.typeLabel.split(' ')[0],
                style: const TextStyle(fontSize: 20)),
          ),
        ),
        title: Text(resource.title, style: AppTextStyles.titleSmall),
        subtitle: Text(
          resource.isFree
              ? 'Pulsuz • ${resource.downloadCount} yükləmə'
              : '₼${resource.price.toStringAsFixed(2)} • ${resource.downloadCount} yükləmə',
          style: AppTextStyles.labelSmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
          onPressed: () =>
              provider.deleteResource(resource.id, widget.courseId),
        ),
      ),
    );
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

  void _addResource() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController(text: '0');
    String resourceType = 'pdf';
    bool isFree = true;

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
              Text('Yeni Resurs', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Resurs adı'),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(hintText: 'Təsvir (ixtiyari)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: resourceType,
                decoration: const InputDecoration(hintText: 'Tip'),
                items: const [
                  DropdownMenuItem(value: 'pdf', child: Text('📄 PDF')),
                  DropdownMenuItem(value: 'template', child: Text('📋 Şablon')),
                  DropdownMenuItem(
                      value: 'source_code', child: Text('💻 Kod')),
                  DropdownMenuItem(value: 'asset', child: Text('🎨 Asset')),
                  DropdownMenuItem(value: 'other', child: Text('📦 Digər')),
                ],
                onChanged: (v) =>
                    setSheetState(() => resourceType = v ?? 'pdf'),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Pulsuz'),
                value: isFree,
                onChanged: (v) => setSheetState(() => isFree = v),
                contentPadding: EdgeInsets.zero,
              ),
              if (!isFree) ...[
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Qiymət',
                    prefixText: '₼ ',
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    // Pick a file
                    final result = await FilePicker.platform.pickFiles();
                    if (result != null && titleController.text.isNotEmpty) {
                      final fileName = result.files.single.name;
                      // For now use a placeholder URL — in prod upload to Supabase Storage
                      final fileUrl = 'storage://resources/$fileName';

                      final provider = Provider.of<ResourceProvider>(context,
                          listen: false);
                      await provider.addResource(
                        courseId: widget.courseId,
                        title: titleController.text,
                        description: descController.text.isNotEmpty
                            ? descController.text
                            : null,
                        resourceType: resourceType,
                        fileUrl: fileUrl,
                        price: isFree
                            ? 0.0
                            : double.tryParse(priceController.text) ?? 0.0,
                        isFree: isFree,
                      );

                      if (mounted) Navigator.pop(ctx);
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Fayl seç və yüklə'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
