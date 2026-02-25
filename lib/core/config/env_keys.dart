/// TEMPORARY ENV KEYS FOR LOCAL APK DEPLOYMENT
/// ⚠️ WARNING: DO NOT COMMIT REAL KEYS TO PUBLIC REPO
/// These keys will be injected into Edge Function headers as a fallback 
/// since the user cannot run `supabase secrets set` on their hosted instance right now.
class EnvKeys {
  static const String groqApiKey = ''; // TODO: User must fill this before building APK
  static const String googleSaJsonB64 = ''; // TODO: User must fill this before building APK
  static const String googleCloudProjectId = ''; // TODO: User must fill this before building APK
  static const String googleCloudLocation = 'us';
  static const String documentAiProcessorId = ''; // TODO: User must fill this before building APK
  static const String gcsBucketTemp = ''; // TODO: User must fill this before building APK

  /// Generates the headers map to inject into Supabase Edge Function calls
  static Map<String, String> get headers => {
        'x-env-groq-api-key': groqApiKey,
        'x-env-google-sa-json-b64': googleSaJsonB64,
        'x-env-google-cloud-project-id': googleCloudProjectId,
        'x-env-google-cloud-location': googleCloudLocation,
        'x-env-document-ai-processor-id': documentAiProcessorId,
        'x-env-gcs-bucket-temp': gcsBucketTemp,
      };
}
