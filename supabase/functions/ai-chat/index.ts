import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { handleCors, jsonResponse, errorResponse } from "../_shared/cors.ts";
import { createServiceClient, getUserId } from "../_shared/supabase-client.ts";
import { Logger } from "../_shared/logger.ts";

const log = new Logger("ai-chat");

/**
 * ai-chat Edge Function
 * Backward-compatible proxy for all AI chat operations.
 * Routes: generate_faqs, answer_question, generate_description,
 *         generate_exam_questions, grade_assignment
 *
 * API keys read from Deno.env.get() — NEVER sent to client.
 */
serve(async (req: Request) => {
    const corsResp = handleCors(req);
    if (corsResp) return corsResp;

    try {
        const userId = await getUserId(req);
        if (!userId) return errorResponse("Unauthorized", 401);

        const body = await req.json();
        const action = body.action as string;

        if (!action) return errorResponse("Missing 'action' field");

        log.info("Action received", { action, userId });

        switch (action) {
            case "generate_faqs":
                return await handleGenerateFaqs(body);
            case "answer_question":
                return await handleAnswerQuestion(body);
            case "generate_description":
                return await handleGenerateDescription(body);
            case "generate_exam_questions":
                return await handleGenerateExamQuestions(body);
            case "grade_assignment":
                return await handleGradeAssignment(body);
            default:
                return errorResponse(`Unknown action: ${action}`);
        }
    } catch (err) {
        log.error("Unhandled error", err);
        return errorResponse("Internal server error", 500);
    }
});

// ── Groq API caller ────────────────────────────────────────
async function callGroq(params: {
    systemPrompt: string;
    userPrompt: string;
    maxTokens?: number;
    temperature?: number;
    base64Image?: string;
    imageMime?: string;
}): Promise<string | null> {
    const apiKey = Deno.env.get("GROQ_API_KEY");
    if (!apiKey) {
        log.error("GROQ_API_KEY not set in secrets!");
        return null;
    }

    const model = params.base64Image
        ? "llama-3.2-90b-vision-preview"
        : "llama-3.3-70b-versatile";

    let userContent: unknown;
    if (params.base64Image) {
        userContent = [
            { type: "text", text: params.userPrompt },
            {
                type: "image_url",
                image_url: {
                    url: `data:${params.imageMime ?? "image/jpeg"};base64,${params.base64Image}`,
                },
            },
        ];
    } else {
        userContent = params.userPrompt;
    }

    const maxRetries = 2;
    for (let attempt = 0; attempt < maxRetries; attempt++) {
        try {
            const resp = await fetch("https://api.groq.com/openai/v1/chat/completions", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    Authorization: `Bearer ${apiKey}`,
                },
                body: JSON.stringify({
                    model,
                    messages: [
                        { role: "system", content: params.systemPrompt },
                        { role: "user", content: userContent },
                    ],
                    max_tokens: params.maxTokens ?? 1000,
                    temperature: params.temperature ?? 0.7,
                }),
            });

            if (resp.ok) {
                const data = await resp.json();
                return data.choices?.[0]?.message?.content ?? null;
            }

            if (resp.status === 429) {
                log.warn("Rate limited", { attempt });
                await new Promise((r) => setTimeout(r, (attempt + 1) * 3000));
                continue;
            }

            log.error("Groq API error", null, {
                status: resp.status,
                body: await resp.text(),
            });
            return null;
        } catch (err) {
            log.error("Groq fetch error", err, { attempt });
            if (attempt < maxRetries - 1) {
                await new Promise((r) => setTimeout(r, 2000));
            }
        }
    }
    return null;
}

function extractJson(content: string): string {
    let c = content.trim();
    if (c.startsWith("```json")) c = c.substring(7);
    else if (c.startsWith("```")) c = c.substring(3);
    if (c.endsWith("```")) c = c.substring(0, c.length - 3);
    return c.trim();
}

// ── Handlers ───────────────────────────────────────────────

async function handleGenerateFaqs(body: Record<string, unknown>) {
    const content = await callGroq({
        systemPrompt:
            "Sən təhsil platforması üçün FAQ yaradıcısısan. Yalnız Azərbaycan dilində. Yalnız JSON array qaytar.",
        userPrompt: `${body.count ?? 15} ədəd FAQ yarat.
Bölmə: ${body.section_title}
Dərslər: ${(body.lesson_titles as string[])?.join(", ") ?? ""}
Format: [{"question":"...","answer":"...","category":"general|technical|practical"}]`,
        maxTokens: 4000,
    });

    if (content) {
        try {
            const faqs = JSON.parse(extractJson(content));
            return jsonResponse({ faqs });
        } catch {
            log.error("FAQ JSON parse failed", null, { content });
        }
    }
    return jsonResponse({ faqs: [] });
}

async function handleAnswerQuestion(body: Record<string, unknown>) {
    const content = await callGroq({
        systemPrompt: "Sən təhsil köməkçisisən. Azərbaycan dilində cavab ver.",
        userPrompt: `Kurs: ${body.course_title ?? "Naməlum"}, Bölmə: ${body.section_title}, Dərs: ${body.lesson_title}
Sual: ${body.question}
2-5 cümlə cavab ver.`,
        maxTokens: 1000,
        temperature: 0.5,
    });

    return jsonResponse({
        answer: content ?? "Bağışlayın, hazırda cavab verə bilmirəm.",
    });
}

async function handleGenerateDescription(body: Record<string, unknown>) {
    const sections = (body.section_titles as string[]) ?? [];
    const content = await callGroq({
        systemPrompt:
            "Sən kurs təsviri yaradıcısısan. Azərbaycan dilində yaz. Yalnız təsviri qaytar.",
        userPrompt: `Kurs: ${body.course_title}
${body.category ? `Kateqoriya: ${body.category}` : ""}
${sections.length ? `Bölmələr: ${sections.join(", ")}` : ""}
3-5 cümlə peşəkar təsvir yaz.`,
        maxTokens: 300,
    });

    return jsonResponse({ description: content ?? "" });
}

async function handleGenerateExamQuestions(body: Record<string, unknown>) {
    const count = (body.count as number) ?? 5;
    const content = await callGroq({
        systemPrompt: `Sən imtahan sualları yaradıcısısan. Azərbaycan dilində. Çoxdan seçməli suallar yarat. Yalnız JSON array qaytar.`,
        userPrompt: `${count} ədəd test sualı yarat.
Mövzu: ${body.topic_or_text}
Format: [{"question":"...","options":["A","B","C","D"],"correctIndex":0}]`,
        maxTokens: 2500,
        base64Image: body.base64_image as string | undefined,
        imageMime: body.image_mime as string | undefined,
    });

    if (content) {
        try {
            const questions = JSON.parse(extractJson(content));
            return jsonResponse({ questions });
        } catch {
            log.error("Exam questions parse failed");
        }
    }
    return jsonResponse({ questions: [] });
}

async function handleGradeAssignment(body: Record<string, unknown>) {
    const content = await callGroq({
        systemPrompt:
            "Sən müəllimsən. Tələbənin cavabını yoxla. Yalnız JSON qaytar.",
        userPrompt: `Tapşırıq: ${body.assignment_title}
Təsvir: ${body.assignment_description}
Cavab: ${body.student_answer}
Format: {"score": 85, "feedback": "..."}`,
        maxTokens: 800,
    });

    if (content) {
        try {
            return jsonResponse(JSON.parse(extractJson(content)));
        } catch {
            log.error("Grading parse failed");
        }
    }
    return jsonResponse({ score: 0, feedback: "Sistem xətası." });
}
