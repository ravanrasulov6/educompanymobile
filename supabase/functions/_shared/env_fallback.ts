export function getFallbackEnv(req: Request): Record<string, string | undefined> {
    return {
        "GROQ_API_KEY": req.headers.get("x-env-groq-api-key") || undefined,
        "GOOGLE_SA_JSON_B64": req.headers.get("x-env-google-sa-json-b64") || undefined,
        "GOOGLE_CLOUD_PROJECT_ID": req.headers.get("x-env-google-cloud-project-id") || undefined,
        "GOOGLE_CLOUD_LOCATION": req.headers.get("x-env-google-cloud-location") || undefined,
        "DOCUMENT_AI_PROCESSOR_ID": req.headers.get("x-env-document-ai-processor-id") || undefined,
        "GCS_BUCKET_TEMP": req.headers.get("x-env-gcs-bucket-temp") || undefined,
    };
}
