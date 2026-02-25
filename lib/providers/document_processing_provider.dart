import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/ai_document_service.dart';
import '../core/services/ai_job_service.dart';
import '../core/services/ai_export_service.dart';
import '../core/services/ai_question_service.dart';

/// Threshold for using TUS resumable upload (20MB)
const _tusThreshold = 20 * 1024 * 1024;

/// Upload/processing state machine
enum ProcessingState { idle, uploading, processing, completed, error }

/// Provider for document upload, processing, and result display.
class DocumentProcessingProvider extends ChangeNotifier {
  final _docService = AiDocumentService.instance;
  final _jobService = AiJobService.instance;
  final _exportService = AiExportService.instance;
  final _questionService = AiQuestionService.instance;

  // ── State ──────────────────────────────────────────────────
  ProcessingState _state = ProcessingState.idle;
  ProcessingState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Upload progress
  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;

  // Current document
  Map<String, dynamic>? _currentDocument;
  Map<String, dynamic>? get currentDocument => _currentDocument;

  // Current job
  Map<String, dynamic>? _currentJob;
  Map<String, dynamic>? get currentJob => _currentJob;
  String? _currentJobId;
  String? get currentJobId => _currentJobId;

  // Job progress
  double _jobPercent = 0.0;
  double get jobPercent => _jobPercent;
  String _jobStep = '';
  String get jobStep => _jobStep;

  // Document pages (paginated)
  List<Map<String, dynamic>> _pages = [];
  List<Map<String, dynamic>> get pages => _pages;
  int _currentPageIndex = 0;
  int get currentPageIndex => _currentPageIndex;
  int _totalPages = 0;
  int get totalPages => _totalPages;

  // Generated questions
  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> get questions => _questions;
  bool _isGeneratingQuestions = false;
  bool get isGeneratingQuestions => _isGeneratingQuestions;

  // Documents list
  List<Map<String, dynamic>> _documents = [];
  List<Map<String, dynamic>> get documents => _documents;

  // Search
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> get searchResults => _searchResults;

  // Summary
  String? _summary;
  String? get summary => _summary;
  bool _isSummarizing = false;
  bool get isSummarizing => _isSummarizing;

  Timer? _pollTimer;
  RealtimeChannel? _realtimeChannel;

  // ── Upload & Process ───────────────────────────────────────

  /// Upload a file and start processing.
  /// For files >20MB, uses TUS resumable upload with real progress.
  Future<String?> uploadAndProcess({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    try {
      _state = ProcessingState.uploading;
      _errorMessage = null;
      _uploadProgress = 0.0;
      notifyListeners();

      Map<String, dynamic> doc;

      if (bytes.length > _tusThreshold) {
        // TUS resumable upload for large files
        doc = await _docService.uploadDocumentResumable(
          bytes: bytes,
          fileName: fileName,
          mimeType: mimeType,
          onProgress: (sent, total) {
            _uploadProgress = total > 0 ? sent / total : 0;
            notifyListeners();
          },
        );
      } else {
        // Standard upload for small files
        _uploadProgress = 0.3;
        notifyListeners();
        doc = await _docService.uploadDocument(
          bytes: bytes,
          fileName: fileName,
          mimeType: mimeType,
        );
      }

      _currentDocument = doc;
      _uploadProgress = 1.0;
      notifyListeners();

      // 2. Trigger processing
      _state = ProcessingState.processing;
      notifyListeners();

      final jobId = await _docService.processDocument(doc['id']);
      _currentJobId = jobId;

      if (jobId != null) {
        _startJobTracking(jobId);
      }

      return doc['id'] as String?;
    } catch (e) {
      _state = ProcessingState.error;
      _errorMessage = 'Yükləmə uğursuz: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  /// Start tracking job via Supabase Realtime, fallback to polling.
  void _startJobTracking(String jobId) {
    _pollTimer?.cancel();
    _realtimeChannel?.unsubscribe();

    try {
      // Try Realtime first (instant updates)
      _realtimeChannel = Supabase.instance.client
          .channel('job-$jobId')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'ai_jobs',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'id',
              value: jobId,
            ),
            callback: (payload) {
              final newRow = payload.newRecord;
              _handleJobUpdate(newRow);
            },
          )
          .subscribe();

      // Also start polling as safety net (in case Realtime misses)
      _startPollingFallback(jobId);
    } catch (e) {
      debugPrint('[DocumentProcessingProvider] Realtime failed: $e');
      // Fallback to polling only
      _startPollingFallback(jobId);
    }
  }

  /// Handle a job update from Realtime or polling.
  void _handleJobUpdate(Map<String, dynamic> job) {
    _currentJob = job;
    _jobPercent = (job['percent'] as num?)?.toDouble() ?? 0.0;
    _jobStep = job['current_step'] as String? ?? '';

    final status = job['status'] as String? ?? '';

    if (status == 'completed') {
      _state = ProcessingState.completed;
      _jobPercent = 100;
      _pollTimer?.cancel();
      _realtimeChannel?.unsubscribe();
      _loadDocumentPages();
    } else if (status == 'failed') {
      _state = ProcessingState.error;
      _errorMessage = job['error_message'] as String? ?? 'Proses uğursuz';
      _pollTimer?.cancel();
      _realtimeChannel?.unsubscribe();
    }

    notifyListeners();
  }

  /// Polling fallback (every 2 seconds).
  void _startPollingFallback(String jobId) {
    _pollTimer?.cancel();
    _pollTimer = _jobService.pollJobStatus(
      jobId: jobId,
      onUpdate: (job) => _handleJobUpdate(job),
      onComplete: () {
        // Already handled in _handleJobUpdate
      },
      onError: (error) {
        _state = ProcessingState.error;
        _errorMessage = error;
        notifyListeners();
      },
    );
  }

  // ── Pages ──────────────────────────────────────────────────

  /// Load pages for current document.
  Future<void> _loadDocumentPages() async {
    if (_currentDocument == null) return;
    final docId = _currentDocument!['id'] as String;
    _totalPages = (_currentDocument!['page_count'] as int?) ?? 0;

    _pages = await _docService.getDocumentPages(docId);
    _currentPageIndex = 0;
    notifyListeners();
  }

  /// Load a specific document and its pages.
  Future<void> loadDocument(String documentId) async {
    _currentDocument = await _docService.getDocument(documentId);
    if (_currentDocument != null) {
      _totalPages = (_currentDocument!['page_count'] as int?) ?? 0;
      _state = ProcessingState.completed;
      await _loadDocumentPages();
    }
  }

  /// Navigate to a specific page.
  Future<void> goToPage(int pageIndex) async {
    if (_currentDocument == null) return;
    _currentPageIndex = pageIndex;

    final docId = _currentDocument!['id'] as String;
    _pages = await _docService.getDocumentPages(
      docId,
      pageNo: pageIndex + 1,
    );
    notifyListeners();
  }

  void nextPage() {
    if (_currentPageIndex < _totalPages - 1) {
      goToPage(_currentPageIndex + 1);
    }
  }

  void previousPage() {
    if (_currentPageIndex > 0) {
      goToPage(_currentPageIndex - 1);
    }
  }

  // ── Search ─────────────────────────────────────────────────

  Future<void> searchInDocument(String query) async {
    if (_currentDocument == null || query.isEmpty) {
      _searchResults = [];
      _searchQuery = '';
      notifyListeners();
      return;
    }

    _searchQuery = query;
    _searchResults = await _docService.searchInDocument(
      _currentDocument!['id'] as String,
      query,
    );
    notifyListeners();
  }

  // ── Questions ──────────────────────────────────────────────

  /// Generate questions from document.
  Future<void> generateQuestions({
    String questionType = 'mcq',
    int count = 5,
    String difficulty = 'medium',
    int? pageStart,
    int? pageEnd,
  }) async {
    if (_currentDocument == null) return;

    _isGeneratingQuestions = true;
    notifyListeners();

    try {
      final result = await _questionService.generateQuestions(
        documentId: _currentDocument!['id'] as String,
        questionType: questionType,
        count: count,
        difficulty: difficulty,
        pageStart: pageStart,
        pageEnd: pageEnd,
      );

      if (result != null && result['questions'] != null) {
        _questions = List<Map<String, dynamic>>.from(result['questions']);
      }
    } catch (e) {
      debugPrint('[DocumentProcessingProvider] Question gen error: $e');
    }

    _isGeneratingQuestions = false;
    notifyListeners();
  }

  /// Load existing questions for document.
  Future<void> loadQuestions() async {
    if (_currentDocument == null) return;

    _questions = await _questionService.getQuestionsForDocument(
      _currentDocument!['id'] as String,
    );
    notifyListeners();
  }

  // ── Summarize ──────────────────────────────────────────────

  Future<void> summarizeDocument() async {
    if (_currentDocument == null) return;

    _isSummarizing = true;
    notifyListeners();

    _summary = await _exportService.summarize(
      documentId: _currentDocument!['id'] as String,
    );

    _isSummarizing = false;
    notifyListeners();
  }

  // ── Export ─────────────────────────────────────────────────

  Future<String?> exportDocument({
    String format = 'pdf',
    bool includeQuestions = false,
  }) async {
    if (_currentDocument == null) return null;

    final result = await _exportService.exportDocument(
      sourceType: 'document',
      sourceId: _currentDocument!['id'] as String,
      format: format,
      includeQuestions: includeQuestions,
    );

    return result?['download_url'] as String?;
  }

  // ── Documents List ─────────────────────────────────────────

  Future<void> loadDocuments() async {
    _documents = await _docService.getDocuments();
    notifyListeners();
  }

  // ── Retry ──────────────────────────────────────────────────

  Future<void> retryProcessing() async {
    if (_currentDocument == null) return;
    _state = ProcessingState.processing;
    _errorMessage = null;
    notifyListeners();

    final jobId = await _docService.processDocument(
      _currentDocument!['id'] as String,
    );

    if (jobId != null) {
      _currentJobId = jobId;
      _startPollingFallback(jobId);
    }
  }

  // ── Reset ──────────────────────────────────────────────────

  void reset() {
    _pollTimer?.cancel();
    _realtimeChannel?.unsubscribe();
    _realtimeChannel = null;
    _state = ProcessingState.idle;
    _errorMessage = null;
    _uploadProgress = 0;
    _currentDocument = null;
    _currentJob = null;
    _currentJobId = null;
    _jobPercent = 0;
    _jobStep = '';
    _pages = [];
    _questions = [];
    _searchResults = [];
    _searchQuery = '';
    _summary = null;
    _currentPageIndex = 0;
    _totalPages = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }
}
