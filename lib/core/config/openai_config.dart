/// Groq API Configuration (OpenAI-compatible format)
class GeminiConfig {
  GeminiConfig._();

  /// Groq API Key — will be set by user
  static const String apiKey = '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';

  /// Model — Llama 3.3 70B (fastest + best quality on Groq)
  static const String model = 'llama-3.3-70b-versatile';

  /// API URL
  static const String chatUrl = 'https://api.groq.com/openai/v1/chat/completions';

  /// kept for backward compat
  static String get generateUrl => chatUrl;

  /// Max tokens
  static const int faqMaxTokens = 4000;
  static const int qaMaxTokens = 1000;
}
