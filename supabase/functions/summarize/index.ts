import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { handleCors, jsonResponse, errorResponse } from "../_shared/cors.ts";
import { createServiceClient, getUserId } from "../_shared/supabase-client.ts";
import { Logger } from "../_shared/logger.ts";

const log = new Logger("summarize");

/**
 * summarize Edge Function
 * Map-reduce summarization pipeline for large documents.
 *
 * 1. Map: Summarize each chunk individually
 * 2. Reduce: Combine chunk summaries into final summary
 * Handles token limits by processing chunks iteratively.
 */
serve(async (req: Request) => {
    const corsResp = handleCors(req);
    if (corsResp) return corsResp;

    try {
        const userId = await getUserId(req);
        if (!userId) return errorResponse("Unauthorized", 401);

        const { document_id, transcript_id } = await req.json();
        if (!document_id && !transcript_id) {
            return errorResponse("Provide document_id or transcript_id");
        }

        const supabase = createServiceClient();
        const groqApiKey = Deno.env.get("GROQ_API_KEY");
        if (!groqApiKey) throw new Error("GROQ_API_KEY not configured");

        let textChunks: string[] = [];

        if (document_id) {
            const { data: chunks } = await supabase
                .from("ai_document_chunks")
                .select("text")
                .eq("document_id", document_id)
                .order("chunk_index");

            textChunks = (chunks ?? []).map((c) => c.text);
        } else if (transcript_id) {
            const { data: transcript } = await supabase
                .from("ai_transcripts")
                .select("full_text")
                .eq("id", transcript_id)
                .eq("user_id", userId)
                .single();

            if (transcript?.full_text) {
                // Split transcript into ~2000 token chunks
                const words = transcript.full_text.split(/\s+/);
                const chunkSize = 500; // ~2000 tokens
                for (let i = 0; i < words.length; i += chunkSize) {
                    textChunks.push(words.slice(i, i + chunkSize).join(" "));
                }
            }
        }

        if (textChunks.length === 0) {
            return errorResponse("No text found for summarization");
        }

        log.info("Starting map-reduce summarization", {
            chunks: textChunks.length,
            documentId: document_id,
        });

        // ── MAP PHASE ──────────────────────────────────────────
        const chunkSummaries: string[] = [];

        for (let i = 0; i < textChunks.length; i++) {
            const resp = await fetch("https://api.groq.com/openai/v1/chat/completions", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    Authorization: `Bearer ${groqApiKey}`,
                },
                body: JSON.stringify({
                    model: "llama-3.3-70b-versatile",
                    messages: [
                        {
                            role: "system",
                            content: "Sən peşəkar xülasəçisən. Verilən mətni Azərbaycan dilində 2-4 cümlə ilə xülasə et. Əsas fikirləri qoru.",
                        },
                        {
                            role: "user",
                            content: `Aşağıdakı mətni xülasə et:\n\n${textChunks[i]}`,
                        },
                    ],
                    max_tokens: 400,
                    temperature: 0.3,
                }),
            });

            if (resp.ok) {
                const data = await resp.json();
                const summary = data.choices?.[0]?.message?.content ?? "";
                if (summary) chunkSummaries.push(summary);
            }
        }

        // ── REDUCE PHASE ───────────────────────────────────────
        let finalSummary = "";

        if (chunkSummaries.length === 1) {
            finalSummary = chunkSummaries[0];
        } else if (chunkSummaries.length > 1) {
            const combined = chunkSummaries.join("\n\n");

            const reduceResp = await fetch("https://api.groq.com/openai/v1/chat/completions", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    Authorization: `Bearer ${groqApiKey}`,
                },
                body: JSON.stringify({
                    model: "llama-3.3-70b-versatile",
                    messages: [
                        {
                            role: "system",
                            content: "Sən peşəkar xülasəçisən. Verilən xülasələri birləşdirib vahid, tutarlı Azərbaycan dilində xülasə yaz. 5-10 cümlə.",
                        },
                        {
                            role: "user",
                            content: `Aşağıdakı hissə xülasələrini birləşdir:\n\n${combined}`,
                        },
                    ],
                    max_tokens: 800,
                    temperature: 0.3,
                }),
            });

            if (reduceResp.ok) {
                const reduceData = await reduceResp.json();
                finalSummary = reduceData.choices?.[0]?.message?.content ?? chunkSummaries.join(" ");
            } else {
                finalSummary = chunkSummaries.join(" ");
            }
        }

        log.info("Summarization completed", {
            chunks: textChunks.length,
            summaryLength: finalSummary.length,
        });

        return jsonResponse({
            success: true,
            summary: finalSummary,
            chunk_count: textChunks.length,
        });

    } catch (err) {
        log.error("Unhandled error", err);
        return errorResponse("Internal server error", 500);
    }
});
