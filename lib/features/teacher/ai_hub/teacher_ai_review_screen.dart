import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TeacherAiReviewScreen extends StatefulWidget {
  final String documentId;
  const TeacherAiReviewScreen({super.key, required this.documentId});

  @override
  State<TeacherAiReviewScreen> createState() => _TeacherAiReviewScreenState();
}

class _TeacherAiReviewScreenState extends State<TeacherAiReviewScreen> {
  final _sb = Supabase.instance.client;
  bool _isLoading = true;
  bool _isPublishing = false;
  Map<String, dynamic>? _document;
  List<Map<String, dynamic>> _pages = [];

  final _saveStates = <int, String>{}; // page_no -> status ('saving', 'saved', 'error')

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final docRes = await _sb.from('ai_documents').select().eq('id', widget.documentId).single();
      final pagesRes = await _sb.from('ai_document_pages').select().eq('document_id', widget.documentId).order('page_no');

      setState(() {
        _document = docRes;
        _pages = List<Map<String, dynamic>>.from(pagesRes);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[TeacherAiReviewScreen] loadData error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _publishDocument() async {
    setState(() => _isPublishing = true);
    try {
      final res = await _sb.functions.invoke('publish-document', body: {
        'document_id': widget.documentId,
        'publish_notes': 'Müəllim tərəfindən yoxlanıldı',
      });

      if (res.status == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sənəd uğurla dərc edildi!'), backgroundColor: AppColors.success));
          context.pop(); // Go back to Hub
        }
      } else {
        throw Exception(res.data);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dərc edilərkən xəta: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  void _onSaveStateChanged(int pageNo, String state) {
    setState(() {
      _saveStates[pageNo] = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasUnsaved = _saveStates.values.contains('saving');

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Sənəd İcmalı', style: AppTextStyles.headlineSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_saveStates.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                    if (hasUnsaved) ...[
                      const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                      const SizedBox(width: 8),
                      Text('Yadda saxlanılır...', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                    ] else ...[
                      const Icon(Icons.cloud_done, color: AppColors.success, size: 18),
                      const SizedBox(width: 4),
                      Text('Saxlanıldı', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                    ]
                  ],
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _document == null
              ? const Center(child: Text('Sənəd tapılmadı'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _pages.length,
                        itemBuilder: (context, index) {
                          final page = _pages[index];
                          return PageEditCard(
                            documentId: widget.documentId,
                            pageData: page,
                            onStateChanged: (state) => _onSaveStateChanged(page['page_no'], state),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
                        ],
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: (_isPublishing || hasUnsaved) ? null : _publishDocument,
                                icon: _isPublishing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.publish),
                                label: Text(_isPublishing ? 'Dərc edilir...' : 'Dərc Et (Sual Yarat)'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class PageEditCard extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> pageData;
  final Function(String) onStateChanged;

  const PageEditCard({
    super.key,
    required this.documentId,
    required this.pageData,
    required this.onStateChanged,
  });

  @override
  State<PageEditCard> createState() => _PageEditCardState();
}

class _PageEditCardState extends State<PageEditCard> {
  late TextEditingController _controller;
  Timer? _debounce;
  final _sb = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    final initialText = widget.pageData['edited_text'] ?? widget.pageData['clean_text'] ?? widget.pageData['raw_text'] ?? '';
    _controller = TextEditingController(text: initialText);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    widget.onStateChanged('saving');

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 2), () async {
      try {
        final res = await _sb.functions.invoke('save-edits', body: {
          'document_id': widget.documentId,
          'page_no': widget.pageData['page_no'],
          'edited_text': value,
        });

        if (res.status == 200) {
          widget.onStateChanged('saved');
        } else {
          widget.onStateChanged('error');
        }
      } catch (e) {
        widget.onStateChanged('error');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text('Səhifə ${widget.pageData['page_no']}', style: AppTextStyles.labelLarge.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                if (widget.pageData['cleaning_failed'] == true)
                  const Tooltip(message: 'Süni intellekt bu səhifəni təmizləyə bilmədi', child: Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: null,
              minLines: 3,
              onChanged: _onTextChanged,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: AppColors.lightSurface,
                hintText: 'Sənəd mətni...',
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
