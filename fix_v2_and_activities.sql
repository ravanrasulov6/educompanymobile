-- 1. DROP DEPENDENT POLICIES FIRST
DROP POLICY IF EXISTS "Users can view their own submissions" ON public.assignment_submissions;
DROP POLICY IF EXISTS "Users can create their own submissions" ON public.assignment_submissions;
DROP POLICY IF EXISTS "Users can update their own submissions" ON public.assignment_submissions;
DROP POLICY IF EXISTS "Users can view own activities" ON public.student_activities;
DROP POLICY IF EXISTS "Users can log own activities" ON public.student_activities;

-- 2. SYNC assignment_submissions COLUMNS
DO $$ 
BEGIN 
    -- If both exist, migrate and drop user_id
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'assignment_submissions' AND column_name = 'user_id') 
       AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'assignment_submissions' AND column_name = 'student_id') THEN
        UPDATE public.assignment_submissions SET student_id = user_id WHERE student_id IS NULL;
        ALTER TABLE public.assignment_submissions DROP COLUMN user_id;
    -- If only user_id exists, rename it
    ELSIF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'assignment_submissions' AND column_name = 'user_id') THEN
        ALTER TABLE public.assignment_submissions RENAME COLUMN user_id TO student_id;
    END IF;
END $$;

-- 3. ADD MISSING COLUMNS
ALTER TABLE public.assignment_submissions ADD COLUMN IF NOT EXISTS answer_text TEXT;
ALTER TABLE public.assignment_submissions ADD COLUMN IF NOT EXISTS ai_score NUMERIC(5,2);
ALTER TABLE public.assignment_submissions ADD COLUMN IF NOT EXISTS teacher_score NUMERIC(5,2);
ALTER TABLE public.assignment_submissions ADD COLUMN IF NOT EXISTS ai_feedback TEXT;
ALTER TABLE public.assignment_submissions ADD COLUMN IF NOT EXISTS teacher_feedback TEXT;

-- 4. UPDATE STATUS CONSTRAINT
ALTER TABLE public.assignment_submissions DROP CONSTRAINT IF EXISTS assignment_submissions_status_check;
ALTER TABLE public.assignment_submissions ADD CONSTRAINT assignment_submissions_status_check 
    CHECK (status IN ('pending', 'submitted', 'graded', 'failed'));
ALTER TABLE public.assignment_submissions ALTER COLUMN status SET DEFAULT 'pending';

-- 5. RECREATE POLICIES USING student_id
ALTER TABLE public.assignment_submissions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own submissions" ON public.assignment_submissions 
    FOR SELECT USING (auth.uid() = student_id);
CREATE POLICY "Users can create their own submissions" ON public.assignment_submissions 
    FOR INSERT WITH CHECK (auth.uid() = student_id);
CREATE POLICY "Users can update their own submissions" ON public.assignment_submissions 
    FOR UPDATE USING (auth.uid() = student_id);

-- 6. ENSURE profiles AND activities
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS balance NUMERIC(10,2) DEFAULT 0.00;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS streak_days INT DEFAULT 0;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS last_activity_date TIMESTAMPTZ;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS total_points INT DEFAULT 0;

CREATE TABLE IF NOT EXISTS public.student_activities (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    activity_type TEXT NOT NULL,
    course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.student_activities ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own activities" ON public.student_activities FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can log own activities" ON public.student_activities FOR INSERT WITH CHECK (auth.uid() = user_id);
