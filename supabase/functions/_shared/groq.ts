export interface GroqCleanResult {
    clean_text: string;
    changes_summary: string | null;
}

export async function groqCleanText(rawText: string, langHint: 'az' | 'en' | 'mixed' = 'az'): Promise<GroqCleanResult> {
    const groqKey = Deno.env.get("GROQ_API_KEY");
    if (!groqKey) throw new Error("Missing GROQ_API_KEY");

    if (rawText.trim().length <= 15) {
        return { clean_text: rawText, changes_summary: "Too short to clean" };
    }

    const prompt = `
    You are a meticulous OCR text clearer.
    Your task is to fix scanning errors, broken hyphenations, and erratic line breaks in the following OCR text.
    LANGUAGE HINT: ${langHint}.
    
    CRITICAL RULES:
    1. DO NOT add any new information, facts, or commentary. Do not hallucinate.
    2. ONLY fix typos, whitespace, and formatting.
    3. Return ONLY a strict JSON object with this exact structure (NO extra markdown):
       {
         "clean_text": "The fully corrected text",
         "changes_summary": "Short 1-sentence summary of what kind of typos you fixed"
       }
    
    RAW OCR INPUT:
    """
    ${rawText}
    """
    `;

    const startTime = Date.now();
    const res = await fetch("https://api.groq.com/openai/v1/chat/completions", {
        method: "POST",
        headers: {
            "Authorization": `Bearer ${groqKey}`,
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            model: "llama-3.3-70b-versatile",
            response_format: { type: "json_object" },
            messages: [
                { role: "system", content: "You output strictly valid JSON." },
                { role: "user", content: prompt }
            ],
            temperature: 0.1
        })
    });

    if (!res.ok) throw new Error(`Groq error: ${await res.text()}`);

    const data = await res.json();
    const content = data.choices[0]?.message?.content || "{}";

    const duration_ms = Date.now() - startTime;
    console.log(`Groq processed ${rawText.length} chars in ${duration_ms}ms`);

    try {
        const parsed = JSON.parse(content);
        return {
            clean_text: parsed.clean_text || rawText,
            changes_summary: parsed.changes_summary || null
        };
    } catch (e) {
        console.error("Groq JSON parsing failed", e);
        throw new Error("Invalid format returned by Groq");
    }
}
