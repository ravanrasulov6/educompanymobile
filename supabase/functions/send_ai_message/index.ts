import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { conversation_id, content } = await req.json()
  
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  // 1. Get Conversation context
  const { data: conv } = await supabase
    .from('conversations')
    .select('student_id')
    .eq('id', conversation_id)
    .single()

  if (!conv) return new Response("Not found", { status: 404 })

  // 2. Generate AI Reply (Logic for OpenAI/Anthropic goes here)
  const aiReply = "Sizinlə razıyam! Dərsinizlə bağlı hər hansı sualınız varsa kömək edə bilərəm."
  
  // 3. Insert AI message
  const { data: msg, error } = await supabase.from('messages').insert({
    conversation_id,
    content: aiReply,
    sender_type: 'assistant',
    citations: [] // Add RAG citations here if implemented
  })

  return new Response(JSON.stringify({ success: true }), {
    headers: { "Content-Type": "application/json" },
  })
})
