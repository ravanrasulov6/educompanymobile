import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { uploadToGcs } from "../_shared/gcs.ts";
import { batchProcessDocument, processDocumentSync } from "../_shared/document_ai.ts";
import { tryExtractNativePdfText } from "../_shared/pdf_text.ts";
import { createLockOrThrow, hashText } from "../_shared/jobs.ts";
import { createServiceClient, getUserId } from "../_shared/supabase-client.ts";
import { handleCors, jsonResponse, errorResponse } from "../_shared/cors.ts";

const CHUNK_TOKEN_LIMIT = 2000;

serve(async (req: Request) => {
    const corsResp = handleCors(req);
    if (corsResp) return corsResp;

    try {
        const userId = await getUserId(req);
        if (!userId) return errorResponse("Unauthorized", 401);

        const { document_id } = await req.json();
        const supabase = createServiceClient();

        const { data: doc, error: docErr } = await supabase.from("ai_documents").select("*").eq("id", document_id).single();
        if (docErr || !doc) return errorResponse("Document not found", 404);

        // 1. Lock Job (Idempotency)
        const job = await createLockOrThrow(supabase, doc.id, doc.user_id);
        await supabase.from("ai_jobs").update({ status: 'running' }).eq('id', job.id);

        const { data: tempUrlData } = await supabase.storage.from("ai-uploads").createSignedUrl(doc.storage_path, 3600);

        // 2. Optimization: Native PDF Text extraction
        if (doc.file_type === 'pdf') {
            const nativePages = await tryExtractNativePdfText(tempUrlData.signedUrl);

            if (nativePages.length > 0) {
                // PDF was selectable text native. No OCR needed!
                const rows = nativePages.map((txt, i) => ({
                    document_id: doc.id,
                    page_no: i + 1,
                    text: txt, // Will be migrated to final schema shortly
                    // new schema:
                    raw_text: txt,
                    clean_text: txt, // Native text doesn't need groq as much
                    source: "native",
                    word_count: txt.split(/\s+/).length
                }));
                await supabase.from("ai_document_pages").insert(rows);
                await supabase.from("ai_documents").update({ page_count: nativePages.length, status: "draft" }).eq("id", doc.id);
                await supabase.from("ai_jobs").update({ status: 'completed' }).eq('id', job.id);

                return jsonResponse({ status: "completed", message: "Native text extracted", job_id: job.id, draft_ready: true });
            }
        }

        // 3. Needs OCR
        if (doc.file_size_bytes > 20 * 1024 * 1024 || doc.file_type === 'pdf') {
            // LRO Async Flow (Large File or PDF) - Streaming memory-safe
            const fileRes = await fetch(tempUrlData.signedUrl);
            if (!fileRes.ok || !fileRes.body) throw new Error("Supabase Storage fetch body failed");

            const bucket = Deno.env.get("GCS_BUCKET_TEMP")!;
            const timestamp = Date.now();
            const gcsInputPath = `inputs/${doc.user_id}/${doc.id}/${timestamp}.pdf`;
            const gcsOutputPrefix = `outputs/${doc.user_id}/${doc.id}/${timestamp}/`;

            // Stream byte response directly to GCS. Uses 0 RAM.
            await uploadToGcs(bucket, gcsInputPath, fileRes.body, doc.mime_type);

            // Document AI Batch LRO
            const operation = await batchProcessDocument(`gs://${bucket}/${gcsInputPath}`, `gs://${bucket}/${gcsOutputPrefix}`);

            // Return 'polling' status to client
            await supabase.from("ai_jobs").update({
                status: 'polling',
                operation_name: operation.name,
                params: { gcsInputPath, gcsOutputPrefix }
            }).eq('id', job.id);

            return jsonResponse({ status: "polling", job_id: job.id });

        } else {
            // Processing small image synchronously
            const fileRes = await fetch(tempUrlData.signedUrl);
            const arrayBuffer = await fileRes.arrayBuffer(); // Ok as size <= 20MB
            const base64 = btoa(String.fromCharCode.apply(null, Array.from(new Uint8Array(arrayBuffer))));

            const docaiResp = await processDocumentSync(base64, doc.mime_type);
            const text = docaiResp.document?.text || "(Boş)";

            await supabase.from("ai_document_pages").insert({
                document_id: doc.id,
                page_no: 1,
                raw_text: text,
                clean_text: text, // Will be cleaned by poll-document if we forced it, but for sync we bypass Groq to save time, or we can add it here. Let's add it here to be consistent.
                source: "ocr",
                word_count: text.split(/\s+/).length
            });
            await supabase.from("ai_documents").update({ status: "draft", page_count: 1 }).eq("id", doc.id);
            await supabase.from("ai_jobs").update({ status: 'completed' }).eq('id', job.id);

            return jsonResponse({ status: "completed", job_id: job.id, draft_ready: true });
        }
    } catch (e: any) {
        return errorResponse(e.message, 500);
    }
});
