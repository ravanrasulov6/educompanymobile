import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { handleCors, jsonResponse, errorResponse } from "../_shared/cors.ts";
import { createServiceClient, getUserId } from "../_shared/supabase-client.ts";
import { Logger } from "../_shared/logger.ts";

const log = new Logger("speech-to-text");

/**
 * speech-to-text Edge Function
 * Takes a transcript_id, downloads audio from storage, sends to Groq Whisper,
 * stores transcript with timestamps.
 *
 * Flow: Flutter → upload audio → create transcript record → invoke this function
 */
serve(async (req: Request) => {
    const corsResp = handleCors(req);
    if (corsResp) return corsResp;

    try {
        const userId = await getUserId(req);
        if (!userId) return errorResponse("Unauthorized", 401);

        const { transcript_id } = await req.json();
        if (!transcript_id) return errorResponse("Missing transcript_id");

        const supabase = createServiceClient();

        // 1. Fetch transcript record
        const { data: transcript, error: tErr } = await supabase
            .from("ai_transcripts")
            .select("*")
            .eq("id", transcript_id)
            .eq("user_id", userId)
            .single();

        if (tErr || !transcript) {
            return errorResponse("Transcript not found", 404);
        }

        // 2. Create job
        const { data: job } = await supabase
            .from("ai_jobs")
            .insert({
                user_id: userId,
                job_type: "audio_stt",
                transcript_id,
                status: "running",
                total_steps: 3,
                done_steps: 0,
                started_at: new Date().toISOString(),
                heartbeat_at: new Date().toISOString(),
                timeout_at: new Date(Date.now() + 10 * 60 * 1000).toISOString(),
                current_step: "Səs faylı yüklənir...",
            })
            .select()
            .single();

        const jobId = job?.id;

        try {
            // 3. Download audio from storage
            await updateProgress(supabase, jobId, 1, 3, "Səs faylı yüklənir...");

            const { data: audioData, error: dlErr } = await supabase.storage
                .from("ai-uploads")
                .download(transcript.storage_path);

            if (dlErr || !audioData) throw new Error("Failed to download audio file");

            // 4. Send to Groq Whisper
            await updateProgress(supabase, jobId, 2, 3, "Transkript edilir...");

            const groqApiKey = Deno.env.get("GROQ_API_KEY");
            if (!groqApiKey) throw new Error("GROQ_API_KEY not configured");

            const formData = new FormData();
            formData.append("file", audioData, transcript.title || "audio.wav");
            formData.append("model", "whisper-large-v3-turbo");
            formData.append("language", transcript.language || "az");
            formData.append("response_format", "verbose_json");
            formData.append("timestamp_granularities[]", "segment");

            const whisperResp = await fetch(
                "https://api.groq.com/openai/v1/audio/transcriptions",
                {
                    method: "POST",
                    headers: {
                        Authorization: `Bearer ${groqApiKey}`,
                    },
                    body: formData,
                }
            );

            if (!whisperResp.ok) {
                const errBody = await whisperResp.text();
                log.error("Whisper API error", null, {
                    status: whisperResp.status,
                    body: errBody,
                });
                throw new Error(`Whisper API error: ${whisperResp.status}`);
            }

            const whisperData = await whisperResp.json();

            // 5. Extract segments
            const segments = (whisperData.segments ?? []).map(
                (seg: Record<string, unknown>) => ({
                    start: seg.start,
                    end: seg.end,
                    text: seg.text,
                })
            );

            const fullText = whisperData.text ?? "";
            const wordCount = fullText.split(/\s+/).filter(Boolean).length;
            const duration = whisperData.duration ?? 0;

            // 6. Update transcript record
            await supabase.from("ai_transcripts").update({
                full_text: fullText,
                segments: segments,
                word_count: wordCount,
                duration_seconds: duration,
                status: "completed",
            }).eq("id", transcript_id);

            // 7. Mark job completed
            await updateProgress(supabase, jobId, 3, 3, "Transkript tamamlandı");
            await supabase.from("ai_jobs").update({
                status: "completed",
                percent: 100,
                completed_at: new Date().toISOString(),
                result: { word_count: wordCount, duration },
            }).eq("id", jobId);

            await logEvent(supabase, jobId, "info", "completed",
                `Transcript completed: ${wordCount} words, ${duration}s`);

            log.info("STT completed", { transcript_id, wordCount, duration });

            return jsonResponse({
                success: true,
                job_id: jobId,
                transcript_id,
                word_count: wordCount,
                duration,
            });

        } catch (processErr) {
            log.error("STT processing failed", processErr);

            await supabase.from("ai_transcripts").update({
                status: "failed",
            }).eq("id", transcript_id);

            if (jobId) {
                await supabase.from("ai_jobs").update({
                    status: "failed",
                    error_message: processErr instanceof Error
                        ? processErr.message
                        : String(processErr),
                    completed_at: new Date().toISOString(),
                }).eq("id", jobId);

                await logEvent(supabase, jobId, "error", "stt",
                    processErr instanceof Error ? processErr.message : String(processErr),
                    processErr instanceof Error ? processErr.stack : undefined);
            }

            return errorResponse("STT processing failed", 500);
        }
    } catch (err) {
        log.error("Unhandled error", err);
        return errorResponse("Internal server error", 500);
    }
});

async function updateProgress(
    supabase: ReturnType<typeof createServiceClient>,
    jobId: string | undefined,
    done: number,
    total: number,
    step: string
) {
    if (!jobId) return;
    await supabase.from("ai_jobs").update({
        done_steps: done,
        total_steps: total,
        percent: Math.round((done / total) * 100),
        current_step: step,
        heartbeat_at: new Date().toISOString(),
    }).eq("id", jobId);
}

async function logEvent(
    supabase: ReturnType<typeof createServiceClient>,
    jobId: string | undefined,
    type: string,
    step: string,
    message: string,
    errorStack?: string
) {
    if (!jobId) return;
    await supabase.from("ai_job_events").insert({
        job_id: jobId,
        event_type: type,
        step,
        message,
        error_stack: errorStack,
    });
}
