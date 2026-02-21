-- Fix for Exams, Assignments, and AI grading features

-- 1. Create Storage Bucket for courses if it doesn't exist
INSERT INTO storage.buckets (id, name, public) 
VALUES ('courses', 'courses', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for 'courses' bucket
CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING (bucket_id = 'courses');
CREATE POLICY "Authenticated users can upload" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'courses' AND auth.role() = 'authenticated');
CREATE POLICY "Users can update own files" ON storage.objects FOR UPDATE USING (bucket_id = 'courses' AND auth.role() = 'authenticated');
CREATE POLICY "Users can delete own files" ON storage.objects FOR DELETE USING (bucket_id = 'courses' AND auth.role() = 'authenticated');


-- 2. Create EXAMS table
CREATE TABLE IF NOT EXISTS public.exams (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    duration_minutes INT DEFAULT 30,
    passing_score INT DEFAULT 60,
    questions JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ensure instructor_id exists on exams
ALTER TABLE public.exams ADD COLUMN IF NOT EXISTS instructor_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE;

-- RLS policies for Exams
ALTER TABLE public.exams ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Exams viewable by everyone" ON public.exams FOR SELECT USING (true);
CREATE POLICY "Teachers can create exams" ON public.exams FOR INSERT WITH CHECK (auth.uid() = instructor_id);
CREATE POLICY "Teachers can update own exams" ON public.exams FOR UPDATE USING (auth.uid() = instructor_id);
CREATE POLICY "Teachers can delete own exams" ON public.exams FOR DELETE USING (auth.uid() = instructor_id);


-- 3. Create ASSIGNMENTS table
CREATE TABLE IF NOT EXISTS public.assignments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    due_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ensure instructor_id exists on assignments
ALTER TABLE public.assignments ADD COLUMN IF NOT EXISTS instructor_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE;

-- RLS policies for Assignments
ALTER TABLE public.assignments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Assignments viewable by everyone" ON public.assignments FOR SELECT USING (true);
CREATE POLICY "Teachers can create assignments" ON public.assignments FOR INSERT WITH CHECK (auth.uid() = instructor_id);
CREATE POLICY "Teachers can update own assignments" ON public.assignments FOR UPDATE USING (auth.uid() = instructor_id);
CREATE POLICY "Teachers can delete own assignments" ON public.assignments FOR DELETE USING (auth.uid() = instructor_id);


-- 4. Create ASSIGNMENT_SUBMISSIONS table for AI Grading
CREATE TABLE IF NOT EXISTS public.assignment_submissions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    assignment_id UUID REFERENCES public.assignments(id) ON DELETE CASCADE,
    answer_text TEXT,
    file_url TEXT,
    ai_feedback TEXT,
    ai_score INT,
    teacher_feedback TEXT,
    teacher_score INT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'graded', 'failed')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ensure student_id exists and is unique per assignment
ALTER TABLE public.assignment_submissions ADD COLUMN IF NOT EXISTS student_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE;
DO $$ BEGIN
    ALTER TABLE public.assignment_submissions ADD CONSTRAINT unique_assignment_student UNIQUE(assignment_id, student_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- RLS policies for Submissions
ALTER TABLE public.assignment_submissions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Students can view own submissions" ON public.assignment_submissions FOR SELECT USING (auth.uid() = student_id);
CREATE POLICY "Teachers can view submissions for their assignments" ON public.assignment_submissions FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.assignments a WHERE a.id = assignment_id AND a.instructor_id = auth.uid())
);
CREATE POLICY "Students can submit answers" ON public.assignment_submissions FOR INSERT WITH CHECK (auth.uid() = student_id);
CREATE POLICY "Students can update unfrozen submissions" ON public.assignment_submissions FOR UPDATE USING (auth.uid() = student_id AND status = 'pending');
CREATE POLICY "Teachers can grade submissions" ON public.assignment_submissions FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.assignments a WHERE a.id = assignment_id AND a.instructor_id = auth.uid())
);
