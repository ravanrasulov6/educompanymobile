-- EDUCOMPANY RLS SECURITY FIX SCRIPT
-- This script enables Row Level Security (RLS) for all tables and defines proper access policies.

-- 1. Enable RLS for all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.course_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assignment_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_results ENABLE ROW LEVEL SECURITY;

-- 2. Clean up existing policies (to avoid duplicates if run multiple times)
DO $$
DECLARE
    pol_name TEXT;
    tab_name TEXT;
BEGIN
    FOR pol_name, tab_name IN 
        SELECT policyname, tablename FROM pg_policies WHERE schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I', pol_name, tab_name);
    END LOOP;
END $$;

-- 3. Define Read-Only Policies (Viewable by everyone)
-- Categories
CREATE POLICY "Categories are viewable by everyone" ON public.categories FOR SELECT USING (true);

-- Courses
CREATE POLICY "Courses are viewable by everyone" ON public.courses FOR SELECT USING (true);

-- Sections
CREATE POLICY "Sections are viewable by everyone" ON public.course_sections FOR SELECT USING (true);

-- Lessons
CREATE POLICY "Lessons are viewable by everyone" ON public.lessons FOR SELECT USING (true);

-- Assignments
CREATE POLICY "Assignments are viewable by everyone" ON public.assignments FOR SELECT USING (true);

-- Exams
CREATE POLICY "Exams are viewable by everyone" ON public.exams FOR SELECT USING (true);

-- Exam Questions
CREATE POLICY "Exam questions are viewable by everyone" ON public.exam_questions FOR SELECT USING (true);

-- 4. Define User-Specific Policies (Authenticated Users)

-- Profiles
CREATE POLICY "Profiles are viewable by everyone" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can update their own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Enrollments
CREATE POLICY "Users can view their own enrollments" ON public.enrollments FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can enroll themselves" ON public.enrollments FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Lesson Progress
CREATE POLICY "Users can view their own lesson progress" ON public.lesson_progress FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update their own lesson progress" ON public.lesson_progress FOR ALL USING (auth.uid() = user_id);

-- Assignment Submissions
CREATE POLICY "Users can view their own submissions" ON public.assignment_submissions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create their own submissions" ON public.assignment_submissions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own submissions" ON public.assignment_submissions FOR UPDATE USING (auth.uid() = user_id);

-- Exam Results
CREATE POLICY "Users can view their own exam results" ON public.exam_results FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own exam results" ON public.exam_results FOR INSERT WITH CHECK (auth.uid() = user_id);
