import { createClient, SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

/**
 * Create a Supabase client with service role (for DB writes from Edge Functions).
 * NEVER expose service role key to client!
 */
export function createServiceClient(): SupabaseClient {
    return createClient(
        Deno.env.get("SUPABASE_URL") ?? "",
        Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
        {
            auth: {
                autoRefreshToken: false,
                persistSession: false,
            },
        }
    );
}

/**
 * Create a Supabase client scoped to the authenticated user (for RLS).
 */
export function createUserClient(req: Request): SupabaseClient {
    const authHeader = req.headers.get("Authorization") ?? "";
    return createClient(
        Deno.env.get("SUPABASE_URL") ?? "",
        Deno.env.get("SUPABASE_ANON_KEY") ?? "",
        {
            global: { headers: { Authorization: authHeader } },
            auth: {
                autoRefreshToken: false,
                persistSession: false,
            },
        }
    );
}

/**
 * Extract user ID from JWT token in request
 */
export async function getUserId(req: Request): Promise<string | null> {
    const client = createUserClient(req);
    const { data: { user }, error } = await client.auth.getUser();
    if (error || !user) return null;
    return user.id;
}
