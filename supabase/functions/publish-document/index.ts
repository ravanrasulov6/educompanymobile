import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createServiceClient, getUserId } from "../_shared/supabase-client.ts";
import { handleCors, jsonResponse, errorResponse } from "../_shared/cors.ts";

serve(async (req: Request) => {
    const corsResp = handleCors(req);
    if (corsResp) return corsResp;

    try {
        const userId = await getUserId(req);
        if (!userId) return errorResponse("Unauthorized", 401);

        const { document_id, title, notes, trigger_qgen = true } = await req.json();
        const supabase = createServiceClient();

        const { data: doc } = await supabase.from('ai_documents').select('*').eq('id', document_id).single();
        if (!doc) return errorResponse("Not found", 404);
        if (doc.user_id !== userId) return errorResponse("Forbidden", 403);
        if (doc.status === 'published') return errorResponse("Already published", 409); // Idempotency check
        if (doc.status !== 'draft') return errorResponse("Document must be in 'draft' to publish", 400);

        // Fetch pages to establish final_text rules
        const { data: pages } = await supabase.from('ai_document_pages')
            .select('page_no, edited_text, clean_text, raw_text')
            .eq('document_id', document_id)
            .order('page_no', { ascending: true });

        const snapshotData = pages?.map(p => ({
            page_no: p.page_no,
            // PRIORITIZATION RULE
            final_text: p.edited_text ?? p.clean_text ?? p.raw_text ?? ''
        })) || [];

        const nextVersion = (doc.active_version || 0) + 1;
        const now = new Date().toISOString();

        // 1. Insert Version Snapshot (Immutable)
        const { data: versionDoc, error: vErr } = await supabase.from('ai_document_versions').insert({
            document_id: document_id,
            version: nextVersion,
            created_by: userId,
            created_at: now,
            snapshot_json: snapshotData,
            publish_notes: notes || null
        }).select().single();

        if (vErr) throw vErr;

        // 2. Update Document Status
        await supabase.from('ai_documents').update({
            status: 'published',
            published_at: now,
            active_version: nextVersion,
            file_name: title || doc.file_name
        }).eq('id', document_id);

        // 3. Trigger Question Generation (Async via Webhook/Job)
        if (trigger_qgen) {
            await supabase.from("ai_jobs").insert({
                document_id: document_id,
                user_id: userId,
                status: 'queued',
                job_type: 'generate_questions',
                params: { version_id: versionDoc.id } // Only feed the finalized text
            });
        }

        return jsonResponse({ success: true, status: 'published', version: nextVersion, version_id: versionDoc.id });
    } catch (e: any) {
        return errorResponse(e.message, 500);
    }
});
