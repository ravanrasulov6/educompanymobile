import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../core/services/ai_transcript_service.dart';
import '../core/services/ai_job_service.dart';
import '../core/services/ai_question_service.dart';
import '../core/services/ai_export_service.dart';

/// Provider for audio recording, upload, and transcript management.
class TranscriptProvider extends ChangeNotifier {
  final _transcriptService = AiTranscriptService.instance;
  final _jobService = AiJobService.instance;
  final _questionService = AiQuestionService.instance;
  final _exportService = AiExportService.instance;

  // ── State ──────────────────────────────────────────────────
  bool _isRecording = false;
  bool get isRecording => _isRecording;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Current transcript
  Map<String, dynamic>? _currentTranscript;
  Map<String, dynamic>? get currentTranscript => _currentTranscript;

  // Job progress
  double _jobPercent = 0.0;
  double get jobPercent => _jobPercent;
  String _jobStep = '';
  String get jobStep => _jobStep;
  String? _currentJobId;
  String? get currentJobId => _currentJobId;

  // Questions
  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> get questions => _questions;
  bool _isGeneratingQuestions = false;
  bool get isGeneratingQuestions => _isGeneratingQuestions;

  // Transcript list
  List<Map<String, dynamic>> _transcripts = [];
  List<Map<String, dynamic>> get transcripts => _transcripts;

  Timer? _pollTimer;

  // ── Recording ──────────────────────────────────────────────

  void startRecording() {
    _isRecording = true;
    notifyListeners();
  }

  void stopRecording() {
    _isRecording = false;
    notifyListeners();
  }

  // ── Upload & Process ───────────────────────────────────────

  /// Upload audio and start STT processing.
  Future<String?> uploadAndProcess({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    String language = 'az',
    String? title,
  }) async {
    try {
      _isUploading = true;
      _errorMessage = null;
      notifyListeners();

      // 1. Upload
      final transcript = await _transcriptService.uploadAudio(
        bytes: bytes,
        fileName: fileName,
        mimeType: mimeType,
        language: language,
        title: title,
      );

      _currentTranscript = transcript;
      _isUploading = false;
      _isProcessing = true;
      notifyListeners();

      // 2. Trigger STT
      final jobId = await _transcriptService.processTranscript(
        transcript['id'] as String,
      );

      if (jobId != null) {
        _currentJobId = jobId;
        _startPolling(jobId, transcript['id'] as String);
      }

      return transcript['id'] as String?;
    } catch (e) {
      _isUploading = false;
      _isProcessing = false;
      _errorMessage = 'Yükləmə uğursuz: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  void _startPolling(String jobId, String transcriptId) {
    _pollTimer?.cancel();
    _pollTimer = _jobService.pollJobStatus(
      jobId: jobId,
      onUpdate: (job) {
        _jobPercent = (job['percent'] as num?)?.toDouble() ?? 0.0;
        _jobStep = job['current_step'] as String? ?? '';
        notifyListeners();
      },
      onComplete: () async {
        _isProcessing = false;
        _jobPercent = 100;
        notifyListeners();
        await _loadTranscript(transcriptId);
      },
      onError: (error) {
        _isProcessing = false;
        _errorMessage = error;
        notifyListeners();
      },
    );
  }

  // ── Transcript ─────────────────────────────────────────────

  Future<void> _loadTranscript(String transcriptId) async {
    _currentTranscript = await _transcriptService.getTranscript(transcriptId);
    notifyListeners();
  }

  Future<void> loadTranscript(String transcriptId) async {
    _currentTranscript = await _transcriptService.getTranscript(transcriptId);
    _isProcessing = false;
    notifyListeners();
  }

  Future<void> loadTranscripts() async {
    _transcripts = await _transcriptService.getTranscripts();
    notifyListeners();
  }

  // ── Questions ──────────────────────────────────────────────

  Future<void> generateQuestions({
    String questionType = 'mcq',
    int count = 5,
    String difficulty = 'medium',
  }) async {
    if (_currentTranscript == null) return;

    _isGeneratingQuestions = true;
    notifyListeners();

    try {
      final result = await _questionService.generateQuestions(
        transcriptId: _currentTranscript!['id'] as String,
        questionType: questionType,
        count: count,
        difficulty: difficulty,
      );

      if (result != null && result['questions'] != null) {
        _questions = List<Map<String, dynamic>>.from(result['questions']);
      }
    } catch (e) {
      debugPrint('[TranscriptProvider] Question gen error: $e');
    }

    _isGeneratingQuestions = false;
    notifyListeners();
  }

  Future<void> loadQuestions() async {
    if (_currentTranscript == null) return;
    _questions = await _questionService.getQuestionsForTranscript(
      _currentTranscript!['id'] as String,
    );
    notifyListeners();
  }

  // ── Export ─────────────────────────────────────────────────

  Future<String?> exportTranscript({
    String format = 'pdf',
    bool includeQuestions = false,
  }) async {
    if (_currentTranscript == null) return null;
    final result = await _exportService.exportDocument(
      sourceType: 'transcript',
      sourceId: _currentTranscript!['id'] as String,
      format: format,
      includeQuestions: includeQuestions,
    );
    return result?['download_url'] as String?;
  }

  // ── Reset ──────────────────────────────────────────────────

  void reset() {
    _pollTimer?.cancel();
    _isRecording = false;
    _isUploading = false;
    _isProcessing = false;
    _errorMessage = null;
    _currentTranscript = null;
    _jobPercent = 0;
    _jobStep = '';
    _questions = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
