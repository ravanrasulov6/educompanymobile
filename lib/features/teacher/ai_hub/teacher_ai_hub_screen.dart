import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/ai_document_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class TeacherAiHubScreen extends StatefulWidget {
  const TeacherAiHubScreen({super.key});

  @override
  State<TeacherAiHubScreen> createState() => _TeacherAiHubScreenState();
}

class _TeacherAiHubScreenState extends State<TeacherAiHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _documents = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDocuments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    try {
      final docs = await AiDocumentService.instance.getDocuments();
      setState(() {
        _documents = docs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[TeacherAiHubScreen] error: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getDocsForStatus(String status) {
    if (status == 'processing') {
      return _documents.where((d) => d['status'] == 'processing' || d['status'] == 'failed').toList();
    }
    return _documents.where((d) => d['status'] == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('az', timeago.AzMessages());

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text('AI Sənədlər', style: AppTextStyles.headlineMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Hazırlanır'),
            Tab(text: 'Mqaralama (Draft)'),
            Tab(text: 'Dərc edilib'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_getDocsForStatus('processing')),
                _buildList(_getDocsForStatus('draft'), isDraft: true),
                _buildList(_getDocsForStatus('published')),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/student/ai-tools').then((_) => _loadDocuments()),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Yeni yüklə', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> docs, {bool isDraft = false}) {
    if (docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.document_scanner_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('Sənəd tapılmadı', style: AppTextStyles.bodyLarge),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDocuments,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final doc = docs[index];
          final String title = doc['file_name'] ?? 'Adsız sənəd';
          final String status = doc['status'] ?? 'Bilinmir';
          final DateTime createdAt = DateTime.parse(doc['created_at']);
          final String timeAgo = timeago.format(createdAt, locale: 'az');

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: isDraft ? () {
                context.push('/teacher/ai-hub/review/${doc['id']}').then((_) => _loadDocuments());
              } : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isDraft ? Icons.edit_document : (status == 'published' ? Icons.check_circle : Icons.hourglass_top),
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(timeAgo, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    if (isDraft)
                      const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    if (status == 'processing')
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    if (status == 'failed')
                      const Icon(Icons.error_outline, color: AppColors.error),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
