-- ═══════════════════════════════════════════════════════════════
-- PREMIUM STUDENT FEATURES MIGRATION
-- ═══════════════════════════════════════════════════════════════

-- 1. STREAKS & ATTENDANCE
CREATE TABLE IF NOT EXISTS public.user_streaks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    current_streak INT DEFAULT 0,
    longest_streak INT DEFAULT 0,
    last_activity_date DATE,
    streak_history JSONB DEFAULT '[]'::jsonb, -- Array of dates
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. CONVERSATIONS (AI & TEACHER)
CREATE TABLE IF NOT EXISTS public.conversations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    student_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    participant_id UUID REFERENCES public.profiles(id), -- NULL for AI
    type TEXT CHECK (type IN ('ai', 'teacher')) NOT NULL,
    last_message_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. MESSAGES
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    conversation_id UUID REFERENCES public.conversations(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES public.profiles(id), -- NULL for AI/System
    content TEXT NOT NULL,
    sender_type TEXT CHECK (sender_type IN ('student', 'teacher', 'assistant')) NOT NULL,
    citations JSONB DEFAULT '[]'::jsonb,
    attachments JSONB DEFAULT '[]'::jsonb,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. INDEXES FOR PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON public.messages(conversation_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_conversations_student ON public.conversations(student_id);
CREATE INDEX IF NOT EXISTS idx_messages_unread ON public.messages(conversation_id) WHERE is_read = false;

-- 5. RLS POLICIES
ALTER TABLE public.user_streaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Streaks
DROP POLICY IF EXISTS "Users can view own streaks" ON public.user_streaks;
CREATE POLICY "Users can view own streaks" ON public.user_streaks FOR SELECT USING (auth.uid() = user_id);

-- Conversations
DROP POLICY IF EXISTS "Users can view own conversations" ON public.conversations;
CREATE POLICY "Users can view own conversations" ON public.conversations FOR SELECT USING (auth.uid() = student_id OR auth.uid() = participant_id);

-- Messages
DROP POLICY IF EXISTS "Users can view messages in own conversations" ON public.messages;
CREATE POLICY "Users can view messages in own conversations" ON public.messages 
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.conversations 
            WHERE conversations.id = messages.conversation_id 
            AND (conversations.student_id = auth.uid() OR conversations.participant_id = auth.uid())
        )
    );

DROP POLICY IF EXISTS "Users can send messages" ON public.messages;
CREATE POLICY "Users can send messages" ON public.messages 
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.conversations 
            WHERE conversations.id = messages.conversation_id 
            AND (conversations.student_id = auth.uid() OR conversations.participant_id = auth.uid())
        )
    );

-- 6. REALTIME REGISTRATION
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.conversations;
ALTER PUBLICATION supabase_realtime ADD TABLE public.user_streaks;
