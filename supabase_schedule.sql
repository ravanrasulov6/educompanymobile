-- EDUCOMPANY SCHEDULE TABLE & DATA
-- This script adds the schedules table and populates it with mock events.

-- 1. Create Schedules Table
CREATE TABLE IF NOT EXISTS public.schedules (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
    date_time TIMESTAMPTZ NOT NULL,
    duration_minutes INT DEFAULT 60,
    type TEXT CHECK (type IN ('liveClass', 'assignment', 'exam')) NOT NULL,
    has_reminder BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.schedules ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Schedules are viewable by everyone" ON public.schedules FOR SELECT USING (true);

-- 2. Insert Mock Schedule Data
DO $$
DECLARE
    course_f_id UUID;
    course_d_id UUID;
    course_a_id UUID;
BEGIN
    SELECT id INTO course_f_id FROM public.courses WHERE title = 'Flutter İnkişafı Masterklas' LIMIT 1;
    SELECT id INTO course_a_id FROM public.courses WHERE title = 'Python ilə Süni İntellekt' LIMIT 1;

    INSERT INTO public.schedules (title, course_id, date_time, duration_minutes, type, has_reminder)
    VALUES 
    ('Flutter State Management', course_f_id, now() + interval '2 hours', 90, 'liveClass', true),
    ('Dart OOP Əsasları', course_f_id, now() + interval '1 day', 60, 'liveClass', false),
    ('Todo Tətbiqi Təhvili', course_f_id, now() + interval '3 days', 0, 'assignment', true),
    ('Python AI Viktorinası', course_a_id, now() + interval '5 days', 45, 'exam', false);
END $$;
