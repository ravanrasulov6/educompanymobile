import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createServiceClient, getUserId } from "../_shared/supabase-client.ts";
import { handleCors, jsonResponse, errorResponse } from "../_shared/cors.ts";

serve(async (req: Request) => {
    const corsResp = handleCors(req);
    if (corsResp) return corsResp;

    try {
        const userId = await getUserId(req);
        if (!userId) return errorResponse("Unauthorized", 401);

        const { document_id, page_no, edited_text } = await req.json();
        const supabase = createServiceClient();

        const { data: doc } = await supabase.from('ai_documents')
            .select('user_id, status')
            .eq('id', document_id)
            .single();

        if (!doc) return errorResponse("Not found", 404);
        if (doc.user_id !== userId) return errorResponse("Forbidden", 403);
        if (doc.status !== 'draft') return errorResponse("Document must be in 'draft' status to edit", 400);

        const now = new Date().toISOString();

        const { error } = await supabase.from('ai_document_pages')
            .update({
                edited_text: edited_text,
                edited_by: userId,
                edited_at: now
            })
            .match({ document_id: document_id, page_no: page_no });

        if (error) throw error;

        return jsonResponse({ success: true, saved_at: now });
    } catch (e: any) {
        return errorResponse(e.message, 500);
    }
});
