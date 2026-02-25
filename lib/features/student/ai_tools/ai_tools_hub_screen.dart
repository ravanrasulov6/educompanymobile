import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../providers/document_processing_provider.dart';
import '../../../providers/transcript_provider.dart';
import '../../../core/config/openai_config.dart';
import 'document_scan_screen.dart';

/// AI Tools Hub — main entry point for document, image, and audio upload.
/// Material 3, modern minimal UI, touch-first design.
class AiToolsHubScreen extends StatelessWidget {
  const AiToolsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('AI Alətləri'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Sənədlərinizi AI ilə analiz edin',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'PDF, şəkil və ya səs faylı yükləyin — mətn çıxarılsın, suallar yaradsın.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // Upload cards
            _UploadCard(
              icon: Icons.picture_as_pdf_rounded,
              title: 'PDF Yüklə',
              subtitle: 'Mətn çıxar, OCR et, suallar yarat',
              gradient: [cs.primary, cs.primary.withValues(alpha: 0.7)],
              onTap: () => _pickFile(context, 'pdf'),
            ),
            const SizedBox(height: 16),
            // _UploadCard(
            //   icon: Icons.camera_alt_rounded,
            //   title: 'Kamera ilə Skanla',
            //   subtitle: 'Çoxlu səhifə çək, düzəlt, PDF kimi göndər',
            //   gradient: [cs.secondary, cs.secondary.withValues(alpha: 0.7)],
            //   onTap: () => _openCameraScan(context),
            // ),
            // const SizedBox(height: 16),
            _UploadCard(
              icon: Icons.image_rounded,
              title: 'Şəkil Yüklə (Əl yazısı OCR)',
              subtitle: 'JPG, PNG, HEIC — əl yazısını tanı',
              gradient: [cs.secondary, cs.secondary.withValues(alpha: 0.7)],
              onTap: () => _pickFile(context, 'image'),
            ),
            const SizedBox(height: 16),
            _UploadCard(
              icon: Icons.mic_rounded,
              title: 'Səs Yüklə / Yaz',
              subtitle: 'MP3, WAV — transkript et, suallar yarat',
              gradient: [cs.tertiary, cs.tertiary.withValues(alpha: 0.7)],
              onTap: () => _pickFile(context, 'audio'),
            ),
            const SizedBox(height: 32),

            // Recent documents
            Text(
              'Son sənədlər',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const _RecentDocumentsList(),
          ],
        ),
      ),
    );
  }

  // Future<void> _openCameraScan(BuildContext context) async {
  //   final result = await Navigator.of(context).push<Map<String, dynamic>>(
  //     MaterialPageRoute(builder: (_) => const DocumentScanScreen()),
  //   );

  //   if (result != null && result['bytes'] != null && context.mounted) {
  //     _uploadDocument(
  //       context,
  //       result['bytes'] as Uint8List,
  //       result['fileName'] as String,
  //       'application/pdf',
  //     );
  //   }
  // }

  Future<void> _pickFile(BuildContext context, String type) async {
    final List<String> extensions;
    switch (type) {
      case 'pdf':
        extensions = AiConfig.pdfExtensions;
        break;
      case 'image':
        extensions = AiConfig.imageExtensions;
        break;
      case 'audio':
        extensions = AiConfig.audioExtensions;
        break;
      default:
        extensions = [];
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;

    if (file.bytes == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fayl oxunmadı')),
        );
      }
      return;
    }

    // Validate file size
    final maxSize = type == 'pdf'
        ? AiConfig.maxPdfSize
        : type == 'audio'
            ? AiConfig.maxAudioSize
            : AiConfig.maxImageSize;

    if (file.bytes!.length > maxSize) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Fayl çox böyükdür (max: ${(maxSize / 1024 / 1024).round()}MB)',
            ),
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;

    final mimeType = _guessMimeType(file.name);

    if (type == 'audio') {
      _uploadAudio(context, file.bytes!, file.name, mimeType);
    } else {
      _uploadDocument(context, file.bytes!, file.name, mimeType);
    }
  }

  void _uploadDocument(
    BuildContext context,
    Uint8List bytes,
    String fileName,
    String mimeType,
  ) async {
    final provider = context.read<DocumentProcessingProvider>();
    provider.reset();

    // Navigate to progress screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: _ProcessingScreen(fileName: fileName),
        ),
      ),
    );

    final docId = await provider.uploadAndProcess(
      bytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
    );

    if (docId != null && context.mounted) {
      // Auto-navigate to result when done (handled by _ProcessingScreen)
    }
  }

  void _uploadAudio(
    BuildContext context,
    Uint8List bytes,
    String fileName,
    String mimeType,
  ) async {
    final provider = context.read<TranscriptProvider>();
    provider.reset();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: _AudioProcessingScreen(fileName: fileName),
        ),
      ),
    );

    await provider.uploadAndProcess(
      bytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
    );
  }

  String _guessMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    const mimeMap = {
      'pdf': 'application/pdf',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'heic': 'image/heic',
      'webp': 'image/webp',
      'mp3': 'audio/mpeg',
      'wav': 'audio/wav',
      'm4a': 'audio/mp4',
      'ogg': 'audio/ogg',
    };
    return mimeMap[ext] ?? 'application/octet-stream';
  }
}

// ── Upload Card ───────────────────────────────────────────
class _UploadCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _UploadCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withValues(alpha: 0.7),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Recent documents list ─────────────────────────────────
class _RecentDocumentsList extends StatefulWidget {
  const _RecentDocumentsList();

  @override
  State<_RecentDocumentsList> createState() => _RecentDocumentsListState();
}

class _RecentDocumentsListState extends State<_RecentDocumentsList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentProcessingProvider>().loadDocuments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DocumentProcessingProvider>();
    final docs = provider.documents;

    if (docs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Text(
          'Hələ bir sənəd yoxdur',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final status = doc['status'] as String? ?? '';
        final iconData = _fileTypeIcon(doc['file_type'] as String? ?? '');
        final statusColor = _statusColor(status);

        return ListTile(
          leading: Icon(iconData, size: 28),
          title: Text(
            doc['file_name'] as String? ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${_formatDate(doc['created_at'])} • $status',
            style: TextStyle(color: statusColor, fontSize: 12),
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () {
            if (status == 'completed') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: provider,
                    child: DocumentResultScreen(documentId: doc['id'] as String),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  IconData _fileTypeIcon(String type) {
    switch (type) {
      case 'pdf': return Icons.picture_as_pdf_rounded;
      case 'image': return Icons.image_rounded;
      case 'audio': return Icons.audiotrack_rounded;
      default: return Icons.insert_drive_file_rounded;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed': return Colors.green;
      case 'processing': return Colors.orange;
      case 'failed': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final dt = DateTime.parse(date.toString());
      return '${dt.day}.${dt.month}.${dt.year}';
    } catch (_) {
      return '';
    }
  }
}

// ── Processing Screen (Progress) ──────────────────────────
class _ProcessingScreen extends StatelessWidget {
  final String fileName;
  const _ProcessingScreen({required this.fileName});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DocumentProcessingProvider>();
    final cs = Theme.of(context).colorScheme;

    // Auto-navigate on completion
    if (provider.state == ProcessingState.completed &&
        provider.currentDocument != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: provider,
              child: DocumentResultScreen(
                documentId: provider.currentDocument!['id'] as String,
              ),
            ),
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('İşlənir...')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // File name
              Icon(Icons.description_rounded, size: 64, color: cs.primary),
              const SizedBox(height: 16),
              Text(
                fileName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Progress
              if (provider.state == ProcessingState.uploading) ...[
                LinearProgressIndicator(value: provider.uploadProgress),
                const SizedBox(height: 12),
                const Text('Yüklənir...'),
              ],

              if (provider.state == ProcessingState.processing) ...[
                LinearProgressIndicator(value: provider.jobPercent / 100),
                const SizedBox(height: 12),
                Text(
                  provider.jobStep.isEmpty ? 'İşlənir...' : provider.jobStep,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Text(
                  '${provider.jobPercent.toInt()}%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ],

              if (provider.state == ProcessingState.error) ...[
                Icon(Icons.error_outline_rounded, size: 48, color: cs.error),
                const SizedBox(height: 12),
                Text(
                  provider.errorMessage ?? 'Naməlum xəta',
                  style: TextStyle(color: cs.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => provider.retryProcessing(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Yenidən cəhd et'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Audio Processing Screen ───────────────────────────────
class _AudioProcessingScreen extends StatelessWidget {
  final String fileName;
  const _AudioProcessingScreen({required this.fileName});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TranscriptProvider>();
    final cs = Theme.of(context).colorScheme;

    // Auto-navigate when transcript is ready
    if (!provider.isProcessing &&
        !provider.isUploading &&
        provider.currentTranscript != null &&
        (provider.currentTranscript!['status'] == 'completed')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: provider,
              child: TranscriptResultScreen(
                transcriptId: provider.currentTranscript!['id'] as String,
              ),
            ),
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Transkript edilir...')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.audiotrack_rounded, size: 64, color: cs.primary),
              const SizedBox(height: 16),
              Text(fileName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 32),

              if (provider.isUploading)
                const Column(children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Səs faylı yüklənir...'),
                ]),

              if (provider.isProcessing) ...[
                LinearProgressIndicator(value: provider.jobPercent / 100),
                const SizedBox(height: 12),
                Text(provider.jobStep.isEmpty ? 'Transkript edilir...' : provider.jobStep),
                const SizedBox(height: 8),
                Text('${provider.jobPercent.toInt()}%',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: cs.primary)),
              ],

              if (provider.errorMessage != null) ...[
                Icon(Icons.error_outline_rounded, size: 48, color: cs.error),
                const SizedBox(height: 12),
                Text(provider.errorMessage!, style: TextStyle(color: cs.error)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Document Result Screen ────────────────────────────────
class DocumentResultScreen extends StatefulWidget {
  final String documentId;
  const DocumentResultScreen({super.key, required this.documentId});

  @override
  State<DocumentResultScreen> createState() => _DocumentResultScreenState();
}

class _DocumentResultScreenState extends State<DocumentResultScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentProcessingProvider>().loadDocument(widget.documentId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DocumentProcessingProvider>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.currentDocument?['file_name'] as String? ?? 'Sənəd'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) => _handleAction(context, value),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'questions', child: Text('Suallar yarat')),
              const PopupMenuItem(value: 'summarize', child: Text('Xülasə et')),
              const PopupMenuItem(value: 'reprocess', child: Text('Yenidən analiz et')),
              const PopupMenuItem(value: 'export_pdf', child: Text('PDF Export')),
              const PopupMenuItem(value: 'export_docx', child: Text('DOCX Export')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Sənəddə axtar...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                isDense: true,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          provider.searchInDocument('');
                        },
                      )
                    : null,
              ),
              onSubmitted: (q) => provider.searchInDocument(q),
            ),
          ),

          // Page navigation
          if (provider.totalPages > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: provider.currentPageIndex > 0
                        ? () => provider.previousPage()
                        : null,
                    icon: const Icon(Icons.chevron_left_rounded),
                    tooltip: 'Əvvəlki',
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Səhifə ${provider.currentPageIndex + 1} / ${provider.totalPages}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: provider.currentPageIndex < provider.totalPages - 1
                        ? () => provider.nextPage()
                        : null,
                    icon: const Icon(Icons.chevron_right_rounded),
                    tooltip: 'Sonrakı',
                  ),
                  const Spacer(),
                  // Jump to page
                  SizedBox(
                    width: 64,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: '#',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onSubmitted: (v) {
                        final page = int.tryParse(v);
                        if (page != null && page >= 1 && page <= provider.totalPages) {
                          provider.goToPage(page - 1);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Text budur',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Text content
          Expanded(
            child: provider.pages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.searchQuery.isNotEmpty
                        ? provider.searchResults.length
                        : provider.pages.length,
                    itemBuilder: (context, index) {
                      final page = provider.searchQuery.isNotEmpty
                          ? provider.searchResults[index]
                          : provider.pages[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: cs.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Səhifə ${page['page_no']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: page['source'] == 'ocr'
                                        ? cs.tertiaryContainer
                                        : cs.secondaryContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    page['source'] == 'ocr' ? 'OCR' : 'Native',
                                    style: TextStyle(fontSize: 10, color: cs.onTertiaryContainer),
                                  ),
                                ),
                                const Spacer(),
                                // Generate questions for this page
                                TextButton.icon(
                                  onPressed: () => _generateForPage(context, page['page_no'] as int),
                                  icon: const Icon(Icons.quiz_rounded, size: 16),
                                  label: const Text('Suallar', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SelectableText(
                              page['text'] as String? ?? '',
                              style: const TextStyle(fontSize: 14, height: 1.6),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Questions section
          if (provider.questions.isNotEmpty) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yaradılmış suallar (${provider.questions.length})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...provider.questions.take(5).map((q) => _QuestionTile(question: q)),
                ],
              ),
            ),
          ],

          // Generating indicator
          if (provider.isGeneratingQuestions)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 12),
                  Text('Suallar yaradılır...'),
                ],
              ),
            ),

          // Summary
          if (provider.summary != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.tertiaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Xülasə', style: TextStyle(fontWeight: FontWeight.w700, color: cs.tertiary)),
                  const SizedBox(height: 8),
                  Text(provider.summary!, style: const TextStyle(height: 1.5)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _generateForPage(BuildContext context, int pageNo) {
    final provider = context.read<DocumentProcessingProvider>();
    _showQuestionTypeDialog(context, (type, count, difficulty) {
      provider.generateQuestions(
        questionType: type,
        count: count,
        difficulty: difficulty,
        pageStart: pageNo,
        pageEnd: pageNo,
      );
    });
  }

  void _handleAction(BuildContext context, String action) {
    final provider = context.read<DocumentProcessingProvider>();

    switch (action) {
      case 'questions':
        _showQuestionTypeDialog(context, (type, count, difficulty) {
          provider.generateQuestions(
            questionType: type,
            count: count,
            difficulty: difficulty,
          );
        });
        break;
      case 'summarize':
        provider.summarizeDocument();
        break;
      case 'reprocess':
        provider.retryProcessing();
        break;
      case 'export_pdf':
        _doExport(context, 'pdf');
        break;
      case 'export_docx':
        _doExport(context, 'docx');
        break;
    }
  }

  void _doExport(BuildContext context, String format) async {
    final provider = context.read<DocumentProcessingProvider>();
    final url = await provider.exportDocument(
      format: format,
      includeQuestions: provider.questions.isNotEmpty,
    );

    if (url != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export hazırdır! ($format)')),
      );
      // In production, open URL with url_launcher
    }
  }

  void _showQuestionTypeDialog(
    BuildContext context,
    void Function(String type, int count, String difficulty) onGenerate,
  ) {
    String selectedType = 'mcq';
    int count = 5;
    String difficulty = 'medium';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('Sual parametrləri'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sual tipi:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _TypeChip('Test (MCQ)', 'mcq', selectedType, (v) => setState(() => selectedType = v)),
                    _TypeChip('Açıq sual', 'open_ended', selectedType, (v) => setState(() => selectedType = v)),
                    _TypeChip('Doğru/Yanlış', 'true_false', selectedType, (v) => setState(() => selectedType = v)),
                    _TypeChip('Boşluq doldur', 'fill_in_blank', selectedType, (v) => setState(() => selectedType = v)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Say:', style: TextStyle(fontWeight: FontWeight.w600)),
                Slider(
                  value: count.toDouble(),
                  min: 3,
                  max: 20,
                  divisions: 17,
                  label: '$count',
                  onChanged: (v) => setState(() => count = v.toInt()),
                ),
                const SizedBox(height: 8),
                const Text('Çətinlik:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _TypeChip('Asan', 'easy', difficulty, (v) => setState(() => difficulty = v)),
                    _TypeChip('Orta', 'medium', difficulty, (v) => setState(() => difficulty = v)),
                    _TypeChip('Çətin', 'hard', difficulty, (v) => setState(() => difficulty = v)),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ləğv et')),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onGenerate(selectedType, count, difficulty);
                },
                child: const Text('Yarat'),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Type selector chip ────────────────────────────────────
Widget _TypeChip(String label, String value, String selected, void Function(String) onTap) {
  final isSelected = value == selected;
  return ChoiceChip(
    label: Text(label),
    selected: isSelected,
    onSelected: (_) => onTap(value),
  );
}

// ── Question tile ─────────────────────────────────────────
class _QuestionTile extends StatelessWidget {
  final Map<String, dynamic> question;
  const _QuestionTile({required this.question});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question['question_text'] as String? ?? '',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (question['answer_key'] != null) ...[
            const SizedBox(height: 4),
            Text(
              'Cavab: ${question['answer_key']}',
              style: TextStyle(fontSize: 13, color: cs.primary),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Transcript Result Screen ──────────────────────────────
class TranscriptResultScreen extends StatefulWidget {
  final String transcriptId;
  const TranscriptResultScreen({super.key, required this.transcriptId});

  @override
  State<TranscriptResultScreen> createState() => _TranscriptResultScreenState();
}

class _TranscriptResultScreenState extends State<TranscriptResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TranscriptProvider>().loadTranscript(widget.transcriptId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TranscriptProvider>();
    final cs = Theme.of(context).colorScheme;
    final transcript = provider.currentTranscript;

    return Scaffold(
      appBar: AppBar(
        title: Text(transcript?['title'] as String? ?? 'Transkript'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) => _handleAction(context, value),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'questions', child: Text('Suallar yarat')),
              const PopupMenuItem(value: 'export_pdf', child: Text('PDF Export')),
              const PopupMenuItem(value: 'export_docx', child: Text('DOCX Export')),
            ],
          ),
        ],
      ),
      body: transcript == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Dedikləriniz budur',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (transcript['duration_seconds'] != null)
                    Text(
                      'Müddət: ${_formatDuration(transcript['duration_seconds'])}  •  ${transcript['word_count'] ?? 0} söz',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  const SizedBox(height: 24),

                  // Transcript text
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SelectableText(
                      transcript['full_text'] as String? ?? 'Mətn yoxdur',
                      style: const TextStyle(fontSize: 15, height: 1.7),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Segments with timestamps
                  if (transcript['segments'] != null &&
                      (transcript['segments'] as List).isNotEmpty) ...[
                    Text(
                      'Zaman damğaları',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: cs.secondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...(transcript['segments'] as List).map<Widget>((seg) {
                      final start = _formatSeconds(seg['start']);
                      final end = _formatSeconds(seg['end']);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: cs.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$start - $end',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onPrimaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(seg['text'] ?? '', style: const TextStyle(height: 1.5))),
                          ],
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 24),

                  // Ask about questions
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [cs.primaryContainer, cs.secondaryContainer],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Buna aid suallar yaradaq?',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilledButton(
                              onPressed: () => provider.generateQuestions(),
                              child: const Text('Bəli, yarat'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Questions
                  if (provider.isGeneratingQuestions)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  if (provider.questions.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Suallar (${provider.questions.length})',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.primary),
                    ),
                    const SizedBox(height: 8),
                    ...provider.questions.map((q) => _QuestionTile(question: q)),
                  ],
                ],
              ),
            ),
    );
  }

  void _handleAction(BuildContext context, String action) async {
    final provider = context.read<TranscriptProvider>();
    switch (action) {
      case 'questions':
        provider.generateQuestions();
        break;
      case 'export_pdf':
        final url = await provider.exportTranscript(format: 'pdf', includeQuestions: true);
        if (url != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF export hazırdır!')),
          );
        }
        break;
      case 'export_docx':
        final url = await provider.exportTranscript(format: 'docx', includeQuestions: true);
        if (url != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('DOCX export hazırdır!')),
          );
        }
        break;
    }
  }

  String _formatDuration(dynamic seconds) {
    if (seconds == null) return '';
    final secs = (seconds as num).toInt();
    final min = secs ~/ 60;
    final sec = secs % 60;
    return '${min}d ${sec}s';
  }

  String _formatSeconds(dynamic seconds) {
    if (seconds == null) return '0:00';
    final secs = (seconds as num).toInt();
    final min = secs ~/ 60;
    final sec = secs % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }
}
