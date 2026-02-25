import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { handleCors, jsonResponse, errorResponse } from "../_shared/cors.ts";
import { createServiceClient, getUserId } from "../_shared/supabase-client.ts";
import { Logger } from "../_shared/logger.ts";
import { getFallbackEnv } from "../_shared/env_fallback.ts";

const log = new Logger("generate-questions");

/**
 * generate-questions Edge Function
 * Generates questions from document text or transcript using Groq LLM.
 *
 * Question types: mcq, open_ended, true_false, fill_in_blank
 * Supports: global (full doc) or page-specific generation
 * Token optimization: only sends relevant chunks, checks cache hash
 */
serve(async (req: Request) => {
    const corsResp = handleCors(req);
    if (corsResp) return corsResp;

    try {
        const userId = await getUserId(req);
        if (!userId) return errorResponse("Unauthorized", 401);

        const fallbackEnv = getFallbackEnv(req);
        const body = await req.json();
        const {
            document_id,
            transcript_id,
            question_type = "mcq",
            count = 5,
            page_start,
            page_end,
            difficulty = "medium",
        } = body;

        if (!document_id && !transcript_id) {
            return errorResponse("Provide document_id or transcript_id");
        }

        const supabase = createServiceClient();

        // 1. Get source text
        let sourceText = "";
        let sourcePageStart = page_start;
        let sourcePageEnd = page_end;

        if (document_id) {
            // Fetch from chunks or pages
            if (page_start && page_end) {
                // Page-specific: get pages in range
                const { data: pages } = await supabase
                    .from("ai_document_pages")
                    .select("text, page_no")
                    .eq("document_id", document_id)
                    .gte("page_no", page_start)
                    .lte("page_no", page_end)
                    .order("page_no");

                sourceText = (pages ?? []).map((p) => p.text).join("\n\n");
            } else {
                // Global: use chunks (token-optimized)
                const { data: chunks } = await supabase
                    .from("ai_document_chunks")
                    .select("text, page_start, page_end, token_estimate")
                    .eq("document_id", document_id)
                    .order("chunk_index");

                // Select chunks up to token limit (~6000 tokens for question gen)
                let totalTokens = 0;
                const selectedChunks: string[] = [];
                for (const chunk of chunks ?? []) {
                    if (totalTokens + (chunk.token_estimate || 0) > 6000) break;
                    selectedChunks.push(chunk.text);
                    totalTokens += chunk.token_estimate || 0;
                    if (!sourcePageStart) sourcePageStart = chunk.page_start;
                    sourcePageEnd = chunk.page_end;
                }
                sourceText = selectedChunks.join("\n\n");
            }
        } else if (transcript_id) {
            const { data: transcript } = await supabase
                .from("ai_transcripts")
                .select("full_text")
                .eq("id", transcript_id)
                .eq("user_id", userId)
                .single();

            sourceText = transcript?.full_text ?? "";
        }

        if (!sourceText.trim()) {
            return errorResponse("No text found for question generation");
        }

        // 2. Check cache — avoid duplicate generation for same text
        const textHash = await hashText(sourceText + question_type + count + difficulty);
        const { data: existing } = await supabase
            .from("ai_questions")
            .select("id")
            .eq("source_text_hash", textHash)
            .eq("user_id", userId)
            .limit(1);

        if (existing && existing.length > 0) {
            log.info("Cache hit for question generation", { textHash });
            // Return existing questions for this hash
            const { data: cachedQuestions } = await supabase
                .from("ai_questions")
                .select("*")
                .eq("source_text_hash", textHash)
                .eq("user_id", userId);

            return jsonResponse({ questions: cachedQuestions ?? [], cached: true });
        }

        // 3. Create job
        const { data: job } = await supabase.from("ai_jobs").insert({
            user_id: userId,
            job_type: "question_gen",
            document_id: document_id || null,
            transcript_id: transcript_id || null,
            status: "running",
            total_steps: 2,
            done_steps: 0,
            started_at: new Date().toISOString(),
            heartbeat_at: new Date().toISOString(),
            params: { question_type, count, difficulty },
            current_step: "Suallar yaradılır...",
        }).select().single();

        // 4. Generate questions via Groq
        const groqApiKey = Deno.env.get("GROQ_API_KEY") || fallbackEnv["GROQ_API_KEY"];
        if (!groqApiKey) throw new Error("GROQ_API_KEY not configured");

        const prompt = buildPrompt(question_type, count, difficulty, sourceText);

        const aiResp = await fetch("https://api.groq.com/openai/v1/chat/completions", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${groqApiKey}`,
            },
            body: JSON.stringify({
                model: "llama-3.3-70b-versatile",
                messages: [
                    { role: "system", content: prompt.system },
                    { role: "user", content: prompt.user },
                ],
                max_tokens: 3000,
                temperature: 0.7,
            }),
        });

        if (!aiResp.ok) {
            throw new Error(`Groq error: ${aiResp.status}`);
        }

        const aiData = await aiResp.json();
        const rawContent = aiData.choices?.[0]?.message?.content ?? "[]";

        // 5. Parse and store questions
        let questions: Array<Record<string, unknown>> = [];
        try {
            questions = JSON.parse(extractJson(rawContent));
        } catch {
            log.error("Failed to parse questions JSON", null, { rawContent });
            throw new Error("AI returned invalid JSON for questions");
        }

        const insertRows = questions.map((q) => ({
            user_id: userId,
            document_id: document_id || null,
            transcript_id: transcript_id || null,
            question_type,
            question_text: q.question ?? q.question_text ?? "",
            options: q.options ? JSON.stringify(q.options) : null,
            answer_key: q.answer ?? q.answer_key ?? "",
            correct_index: q.correctIndex ?? q.correct_index ?? null,
            difficulty,
            source_page_start: sourcePageStart ?? null,
            source_page_end: sourcePageEnd ?? null,
            source_text_hash: textHash,
        }));

        const { data: savedQuestions, error: insertErr } = await supabase
            .from("ai_questions")
            .insert(insertRows)
            .select();

        if (insertErr) {
            log.error("Failed to save questions", insertErr);
        }

        // 6. Update job
        if (job?.id) {
            await supabase.from("ai_jobs").update({
                status: "completed",
                done_steps: 2,
                percent: 100,
                completed_at: new Date().toISOString(),
                current_step: "Suallar hazırdır",
                result: { question_count: savedQuestions?.length ?? 0 },
            }).eq("id", job.id);
        }

        log.info("Questions generated", {
            count: savedQuestions?.length ?? 0,
            type: question_type,
        });

        return jsonResponse({
            success: true,
            questions: savedQuestions ?? [],
            job_id: job?.id,
        });

    } catch (err) {
        log.error("Unhandled error", err);
        return errorResponse("Internal server error", 500);
    }
});

// ── Prompt builder ────────────────────────────────────────
function buildPrompt(
    type: string,
    count: number,
    difficulty: string,
    text: string
): { system: string; user: string } {
    const difficultyMap: Record<string, string> = {
        easy: "Asan",
        medium: "Orta",
        hard: "Çətin",
    };
    const diffLabel = difficultyMap[difficulty] ?? "Orta";

    const typeInstructions: Record<string, string> = {
        mcq: `Çoxdan seçməli (4 variantlı) test sualları yarat.
Format: [{"question":"...","options":["A","B","C","D"],"correctIndex":0,"answer":"düzgün cavab"}]`,

        open_ended: `Açıq suallar yarat. Cavab 1-3 cümlə olsun.
Format: [{"question":"...","answer":"gözlənilən cavab"}]`,

        true_false: `Doğru/Yanlış sualları yarat.
Format: [{"question":"...ifadə...","answer":"Doğru" yaxud "Yanlış"}]`,

        fill_in_blank: `Boşluq doldurun sualları yarat. Sualda ___ işarəsi ilə boşluq göstər.
Format: [{"question":"___ bu ideyanın əsas prinsipidir.","answer":"düzgün söz/ifadə"}]`,
    };

    return {
        system: `Sən təhsil mütəxəssisisən. Azərbaycan dilində suallar yarat. Yalnız JSON array qaytar, başqa heç nə yazma. Səviyyə: ${diffLabel}.`,
        user: `Aşağıdakı mətnə əsasən ${count} ədəd sual yarat.

${typeInstructions[type] ?? typeInstructions.mcq}

Mətn:
${text.substring(0, 8000)}`,
    };
}

function extractJson(content: string): string {
    let c = content.trim();
    if (c.startsWith("```json")) c = c.substring(7);
    else if (c.startsWith("```")) c = c.substring(3);
    if (c.endsWith("```")) c = c.substring(0, c.length - 3);
    return c.trim();
}

async function hashText(text: string): Promise<string> {
    const data = new TextEncoder().encode(text);
    const hash = await crypto.subtle.digest("SHA-256", data);
    return Array.from(new Uint8Array(hash))
        .map((b) => b.toString(16).padStart(2, "0"))
        .join("");
}
