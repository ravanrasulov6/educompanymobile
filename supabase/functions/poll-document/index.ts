import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { getOperationStatus } from "../_shared/document_ai.ts";
import { readGcsObjectJson, listGcsObjects, deleteGcsObject } from "../_shared/gcs.ts";
import { groqCleanText } from "../_shared/groq.ts";
import { createServiceClient } from "../_shared/supabase-client.ts";
import { handleCors, jsonResponse, errorResponse } from "../_shared/cors.ts";
import pLimit from "https://esm.sh/p-limit@4.0.0";

const limit = pLimit(3); // Miximum 3 parallel request to Groq

serve(async (req: Request) => {
    const corsResp = handleCors(req);
    if (corsResp) return corsResp;

    try {
        const supabase = createServiceClient();
        const { job_id } = await req.json();

        const { data: job } = await supabase.from("ai_jobs").select("*").eq("id", job_id).single();
        if (!job || job.status !== 'polling') return jsonResponse({ status: job?.status || 'not_found' });

        const operation = await getOperationStatus(job.operation_name);

        if (!operation.done) {
            await supabase.from("ai_jobs").update({ last_heartbeat_at: new Date().toISOString() }).eq("id", job.id);
            return jsonResponse({ status: "polling" });
        }

        if (operation.error) {
            await supabase.from("ai_jobs").update({ status: 'failed', error_message: JSON.stringify(operation.error) }).eq('id', job.id);
            await supabase.from("ai_documents").update({ status: "failed" }).eq("id", job.document_id);
            return jsonResponse({ status: "failed", error: operation.error });
        }

        const bucket = Deno.env.get("GCS_BUCKET_TEMP")!;
        const { gcsInputPath, gcsOutputPrefix } = job.params;

        // Fetch outputs
        const objectNames = await listGcsObjects(bucket, gcsOutputPrefix);
        const jsonNames = objectNames.filter((n: string) => n.endsWith('.json'));

        const rawPages: any[] = [];

        for (const objName of jsonNames) {
            const jsonOutput = await readGcsObjectJson(bucket, objName);
            if (!jsonOutput.document?.pages) continue;
            const textStr = jsonOutput.document.text || "";

            for (const p of jsonOutput.document.pages) {
                let pageText = "";
                const pNumber = parseInt(p.pageNumber || '1', 10);

                if (p.layout?.textSegment) {
                    const start = parseInt(p.layout.textSegment.startIndex || "0", 10);
                    const end = parseInt(p.layout.textSegment.endIndex || "0", 10);
                    pageText = textStr.substring(start || 0, end || 0);
                }
                rawPages.push({ page_no: pNumber, raw_text: pageText.trim() });
            }
        }

        // Sort ordering
        rawPages.sort((a, b) => a.page_no - b.page_no);

        // A: Run Groq Cleanup on each page concurrently, up to 'limit'
        const dbPages = await Promise.all(rawPages.map((p) => limit(async () => {
            let clean_text = p.raw_text;
            let changes_summary = null;
            let cleaning_failed = false;

            if (p.raw_text.length > 0) {
                try {
                    const groqRes = await groqCleanText(p.raw_text, 'az');
                    clean_text = groqRes.clean_text;
                    changes_summary = groqRes.changes_summary;
                } catch (err) {
                    console.error(`Groq error on page ${p.page_no}:`, err);
                    cleaning_failed = true;
                }
            }

            return {
                document_id: job.document_id,
                page_no: p.page_no,
                raw_text: p.raw_text,
                clean_text: clean_text,
                cleaning_model: 'llama-3.3-70b-versatile',
                cleaning_version: 'v1',
                cleaning_failed: cleaning_failed,
                changes_summary: changes_summary,
                source: 'ocr'
            };
        })));

        // Batch Insert
        for (let i = 0; i < dbPages.length; i += 10) {
            await supabase.from("ai_document_pages").insert(dbPages.slice(i, i + 10));
        }

        // Cleanup temp GCS files
        let cleanupFailed = false;
        try {
            await deleteGcsObject(bucket, gcsInputPath);
            for (const n of jsonNames) await deleteGcsObject(bucket, n);
        } catch { cleanupFailed = true; }

        // MÜTLƏQ: Status 'draft' olur, Teacher Edit edə bilsin
        await supabase.from("ai_documents").update({
            status: "draft",
            page_count: rawPages.length
        }).eq("id", job.document_id);

        await supabase.from("ai_jobs").update({ status: 'completed', cleanup_failed: cleanupFailed }).eq('id', job.id);

        return jsonResponse({ status: "completed", draft_ready: true });
    } catch (e: any) {
        return errorResponse(e.message, 500);
    }
});
