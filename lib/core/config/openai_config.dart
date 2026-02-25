/// AI Service Configuration
/// All AI calls are routed through Supabase Edge Functions.
/// API keys are stored ONLY as Supabase secrets (server-side).
/// Flutter NEVER calls AI providers directly.
class AiConfig {
  AiConfig._();

  /// Edge Function names
  static const String processDocumentFn = 'process-document';
  static const String ocrExtractFn = 'ocr-extract';
  static const String speechToTextFn = 'speech-to-text';
  static const String generateQuestionsFn = 'generate-questions';
  static const String summarizeFn = 'summarize';
  static const String exportDocumentFn = 'export-document';
  static const String jobWorkerFn = 'job-worker';

  /// Kept for backward compatibility — proxied through Edge Function
  static const String aiChatFn = 'ai-chat';

  /// Supported question types
  static const List<String> questionTypes = [
    'mcq',
    'open_ended',
    'true_false',
    'fill_in_blank',
  ];

  /// Supported OCR languages
  static const List<String> ocrLanguages = ['az', 'tr', 'en'];

  /// Max file sizes (bytes)
  static const int maxPdfSize = 150 * 1024 * 1024; // 150MB
  static const int maxImageSize = 20 * 1024 * 1024; // 20MB
  static const int maxAudioSize = 100 * 1024 * 1024; // 100MB

  /// Allowed file extensions
  static const List<String> pdfExtensions = ['pdf'];
  static const List<String> imageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'heic',
    'webp',
    'bmp',
    'tiff',
  ];
  static const List<String> audioExtensions = ['mp3', 'wav', 'm4a', 'ogg', 'webm'];

  /// Chunk settings
  static const int defaultChunkTokenSize = 2000;
  static const int batchPageSize = 5;

  /// Job polling interval
  static const Duration jobPollInterval = Duration(seconds: 2);
}

/// Legacy alias for backward compatibility
typedef GeminiConfig = AiConfig;
