-- Advanced Exam Logic: Addition of Exam Types and Penalty Rules

-- Add exam_type column (if not exists)
ALTER TABLE public.exams ADD COLUMN IF NOT EXISTS type TEXT DEFAULT 'standard' CHECK (type IN ('standard', 'admission', 'block', 'contest'));

-- Add penalty_rule column (if not exists)
ALTER TABLE public.exams ADD COLUMN IF NOT EXISTS penalty_rule TEXT DEFAULT 'none' CHECK (penalty_rule IN ('none', 'two_for_one', 'three_for_one', 'four_for_one'));

-- pass_score already exists from original table layout as passing_score. We will ensure it is correctly utilized in Dart models.
ALTER TABLE public.exams ADD COLUMN IF NOT EXISTS passing_score INT DEFAULT 60;

-- Allow course_id to be NULL for general exams
ALTER TABLE public.exams ALTER COLUMN course_id DROP NOT NULL;

-- Add category column to distinguish between Course Exams and General Mock Exams
ALTER TABLE public.exams ADD COLUMN IF NOT EXISTS category TEXT DEFAULT 'course_evaluation' CHECK (category IN ('course_evaluation', 'general_mock'));
