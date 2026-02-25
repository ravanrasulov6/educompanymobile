import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

export async function updateProgress(
    supabase: SupabaseClient,
    jobId: string,
    done: number,
    total: number,
    stepMessage: string
) {
    const percent = total > 0 ? (done / total) * 100 : 0;
    await supabase.from("ai_jobs").update({
        done_steps: done,
        total_steps: total,
        percent: parseFloat(percent.toFixed(2)),
        current_step: stepMessage,
        heartbeat_at: new Date().toISOString()
    }).eq("id", jobId);
}

export async function heartbeat(supabase: SupabaseClient, jobId: string) {
    const now = new Date();
    // Extend timeout by 10 mins from now
    const timeout = new Date(now.getTime() + 10 * 60000);

    await supabase.from("ai_jobs").update({
        heartbeat_at: now.toISOString(),
        timeout_at: timeout.toISOString()
    }).eq("id", jobId);
}

export async function logEvent(
    supabase: SupabaseClient,
    jobId: string,
    type: 'info' | 'warning' | 'error' | 'progress',
    step: string,
    message: string,
    error?: unknown
) {
    let errorStack = null;
    if (error) {
        if (error instanceof Error) {
            errorStack = error.stack;
            message = `${message}: ${error.message}`;
        } else {
            message = `${message}: ${String(error)}`;
        }
    }

    await supabase.from("ai_job_events").insert({
        job_id: jobId,
        event_type: type,
        step: step,
        message: message,
        error_stack: errorStack
    });
}

/**
 * Memory-safe Base64 encoder for small/medium chunks (replaces string spread)
 */
export function uint8ArrayToBase64(bytes: Uint8Array): string {
    let binary = '';
    const len = bytes.byteLength;
    const chunkSize = 32768; // 32KB chunks
    for (let i = 0; i < len; i += chunkSize) {
        const chunk = bytes.subarray(i, i + chunkSize);
        binary += String.fromCharCode.apply(null, chunk as unknown as number[]);
    }
    return btoa(binary);
}

/**
 * Concurrency utility
 */
export async function pMap<T, R>(items: T[], concurrency: number, fn: (item: T) => Promise<R>): Promise<R[]> {
    const results: R[] = new Array(items.length);
    let index = 0;

    async function worker() {
        while (index < items.length) {
            const currentIndex = index++;
            results[currentIndex] = await fn(items[currentIndex]);
        }
    }

    const workers = Array.from({ length: Math.min(concurrency, items.length) }, worker);
    await Promise.all(workers);
    return results;
}

export async function createLockOrThrow(
    supabase: SupabaseClient,
    documentId: string,
    userId: string
) {
    // Relying on the unique partial index:
    // CREATE UNIQUE INDEX idx_ai_jobs_active_unique_per_doc ON ai_jobs (document_id) ...
    // If a job is already queued/running/polling for this doc, this insert will fail.
    const { data: job, error } = await supabase.from("ai_jobs").insert({
        user_id: userId,
        document_id: documentId,
        job_type: 'pdf_extract',
        status: 'queued',
        heartbeat_at: new Date().toISOString()
    }).select().single();

    if (error) {
        if (error.code === '23505') { // Postgres unique violation code
            throw new Error(`Document ${documentId} is already being processed.`);
        }
        throw error;
    }
    return job;
}

export async function hashText(text: string): Promise<string> {
    const encoder = new TextEncoder();
    const data = encoder.encode(text);
    const hashBuffer = await crypto.subtle.digest('SHA-256', data);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}
