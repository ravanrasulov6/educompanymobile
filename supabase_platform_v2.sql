-- EDUCOMPANY PLATFORM V2 — ADVANCED FEATURES SCHEMA
-- Cədvəlli dərslər, AI/Müəllim sual sistemi, pullu resurslar, mövzu FAQ

-- 0. Ensure UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ═══════════════════════════════════════════════════════════════
-- 1. ALTER courses — price, is_free, status
-- ═══════════════════════════════════════════════════════════════
ALTER TABLE public.courses ADD COLUMN IF NOT EXISTS price NUMERIC(10,2) DEFAULT 0.00;
ALTER TABLE public.courses ADD COLUMN IF NOT EXISTS is_free BOOLEAN DEFAULT true;
ALTER TABLE public.courses ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'draft';

-- Add check constraint safely
DO $$ BEGIN
    ALTER TABLE public.courses ADD CONSTRAINT courses_status_check
        CHECK (status IN ('draft', 'published', 'archived'));
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ═══════════════════════════════════════════════════════════════
-- 2. lesson_schedule — Gün-gün dərs açılma cədvəli
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.lesson_schedule (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
    lesson_id UUID REFERENCES public.lessons(id) ON DELETE CASCADE,
    unlock_date DATE NOT NULL,
    day_number INT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(course_id, lesson_id)
);

CREATE INDEX IF NOT EXISTS idx_lesson_schedule_course ON public.lesson_schedule(course_id);
CREATE INDEX IF NOT EXISTS idx_lesson_schedule_unlock ON public.lesson_schedule(unlock_date);

-- ═══════════════════════════════════════════════════════════════
-- 3. lesson_qa_config — Müəllim tərəfindən hər dərs üçün limit
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.lesson_qa_config (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    lesson_id UUID REFERENCES public.lessons(id) ON DELETE CASCADE,
    ai_question_limit INT DEFAULT 30,
    teacher_question_limit INT DEFAULT 3,
    ai_enabled BOOLEAN DEFAULT true,
    teacher_qa_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(lesson_id)
);

-- ═══════════════════════════════════════════════════════════════
-- 4. student_questions — Tələbə → Müəllim sualları
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.student_questions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    lesson_id UUID REFERENCES public.lessons(id) ON DELETE CASCADE,
    student_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    question TEXT NOT NULL,
    answer TEXT,
    is_answered BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    answered_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_student_questions_lesson ON public.student_questions(lesson_id);
CREATE INDEX IF NOT EXISTS idx_student_questions_student ON public.student_questions(student_id);

-- ═══════════════════════════════════════════════════════════════
-- 5. ai_question_log — Tələbə → AI sual tarixçəsi
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.ai_question_log (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    lesson_id UUID REFERENCES public.lessons(id) ON DELETE CASCADE,
    student_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    question TEXT NOT NULL,
    ai_answer TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_questions_lesson ON public.ai_question_log(lesson_id);
CREATE INDEX IF NOT EXISTS idx_ai_questions_student ON public.ai_question_log(student_id);

-- ═══════════════════════════════════════════════════════════════
-- 6. topic_faqs — Hər bölmə üçün FAQ seksiyası
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.topic_faqs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    section_id UUID REFERENCES public.course_sections(id) ON DELETE CASCADE,
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    category TEXT DEFAULT 'general' CHECK (category IN ('general', 'technical', 'practical')),
    order_index INT DEFAULT 0,
    helpful_count INT DEFAULT 0,
    created_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_topic_faqs_section ON public.topic_faqs(section_id);

-- ═══════════════════════════════════════════════════════════════
-- 7. course_resources — Kursun içindəki pullu/pulsuz resurslar
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.course_resources (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
    section_id UUID REFERENCES public.course_sections(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT,
    resource_type TEXT CHECK (resource_type IN ('pdf', 'template', 'source_code', 'asset', 'other')),
    file_url TEXT NOT NULL,
    price NUMERIC(10,2) DEFAULT 0.00,
    is_free BOOLEAN DEFAULT false,
    download_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_course_resources_course ON public.course_resources(course_id);

-- ═══════════════════════════════════════════════════════════════
-- 8. resource_purchases — Resurs satın alma tarixçəsi
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.resource_purchases (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    resource_id UUID REFERENCES public.course_resources(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    purchased_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(resource_id, user_id)
);

-- ═══════════════════════════════════════════════════════════════
-- 9. ROW LEVEL SECURITY
-- ═══════════════════════════════════════════════════════════════

-- lesson_schedule
ALTER TABLE public.lesson_schedule ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lesson schedules viewable by everyone" ON public.lesson_schedule FOR SELECT USING (true);
CREATE POLICY "Teachers can manage lesson schedules" ON public.lesson_schedule FOR ALL USING (
    EXISTS (SELECT 1 FROM public.courses c JOIN public.profiles p ON c.instructor_id = p.id WHERE c.id = course_id AND p.id = auth.uid())
);

-- lesson_qa_config
ALTER TABLE public.lesson_qa_config ENABLE ROW LEVEL SECURITY;
CREATE POLICY "QA config viewable by everyone" ON public.lesson_qa_config FOR SELECT USING (true);

-- student_questions
ALTER TABLE public.student_questions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Students can view own questions" ON public.student_questions FOR SELECT USING (auth.uid() = student_id);
CREATE POLICY "Students can ask questions" ON public.student_questions FOR INSERT WITH CHECK (auth.uid() = student_id);
CREATE POLICY "Teachers can view questions for their lessons" ON public.student_questions FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.lessons l
        JOIN public.course_sections cs ON l.section_id = cs.id
        JOIN public.courses c ON cs.course_id = c.id
        WHERE l.id = lesson_id AND c.instructor_id = auth.uid()
    )
);
CREATE POLICY "Teachers can answer questions" ON public.student_questions FOR UPDATE USING (
    EXISTS (
        SELECT 1 FROM public.lessons l
        JOIN public.course_sections cs ON l.section_id = cs.id
        JOIN public.courses c ON cs.course_id = c.id
        WHERE l.id = lesson_id AND c.instructor_id = auth.uid()
    )
);

-- ai_question_log
ALTER TABLE public.ai_question_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Students can view own AI questions" ON public.ai_question_log FOR SELECT USING (auth.uid() = student_id);
CREATE POLICY "Students can log AI questions" ON public.ai_question_log FOR INSERT WITH CHECK (auth.uid() = student_id);

-- topic_faqs
ALTER TABLE public.topic_faqs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "FAQs viewable by everyone" ON public.topic_faqs FOR SELECT USING (true);

-- course_resources
ALTER TABLE public.course_resources ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Resources viewable by everyone" ON public.course_resources FOR SELECT USING (true);

-- resource_purchases
ALTER TABLE public.resource_purchases ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own purchases" ON public.resource_purchases FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can purchase resources" ON public.resource_purchases FOR INSERT WITH CHECK (auth.uid() = user_id);
