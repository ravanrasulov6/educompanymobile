-- ═══════════════════════════════════════════════════════════════
-- EDUCOMPANY V2 — FIX: RLS Policies for core tables 
-- Run this in Supabase SQL Editor to fix RLS issues
-- ═══════════════════════════════════════════════════════════════

-- ── 1. COURSES ──────────────────────────────────────────────────
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;

-- Everyone can view published courses
DROP POLICY IF EXISTS "Courses viewable by everyone" ON public.courses;
CREATE POLICY "Courses viewable by everyone" ON public.courses 
  FOR SELECT USING (true);

-- Teachers can insert their own courses
DROP POLICY IF EXISTS "Teachers can create courses" ON public.courses;
CREATE POLICY "Teachers can create courses" ON public.courses 
  FOR INSERT WITH CHECK (auth.uid() = instructor_id);

-- Teachers can update their own courses
DROP POLICY IF EXISTS "Teachers can update own courses" ON public.courses;
CREATE POLICY "Teachers can update own courses" ON public.courses 
  FOR UPDATE USING (auth.uid() = instructor_id);

-- Teachers can delete their own courses
DROP POLICY IF EXISTS "Teachers can delete own courses" ON public.courses;
CREATE POLICY "Teachers can delete own courses" ON public.courses 
  FOR DELETE USING (auth.uid() = instructor_id);

-- ── 2. COURSE_SECTIONS ──────────────────────────────────────────
ALTER TABLE public.course_sections ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Sections viewable by everyone" ON public.course_sections;
CREATE POLICY "Sections viewable by everyone" ON public.course_sections 
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Teachers can manage sections" ON public.course_sections;
CREATE POLICY "Teachers can manage sections" ON public.course_sections 
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.courses c 
      WHERE c.id = course_id AND c.instructor_id = auth.uid()
    )
  );

-- ── 3. LESSONS ──────────────────────────────────────────────────
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Lessons viewable by everyone" ON public.lessons;
CREATE POLICY "Lessons viewable by everyone" ON public.lessons 
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Teachers can manage lessons" ON public.lessons;
CREATE POLICY "Teachers can manage lessons" ON public.lessons 
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.course_sections cs
      JOIN public.courses c ON c.id = cs.course_id
      WHERE cs.id = section_id AND c.instructor_id = auth.uid()
    )
  );

-- ── 4. CATEGORIES ───────────────────────────────────────────────
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Categories viewable by everyone" ON public.categories;
CREATE POLICY "Categories viewable by everyone" ON public.categories 
  FOR SELECT USING (true);

-- ── 5. LESSON_QA_CONFIG — Teachers can manage ───────────────────
DROP POLICY IF EXISTS "Teachers can manage QA config" ON public.lesson_qa_config;
CREATE POLICY "Teachers can manage QA config" ON public.lesson_qa_config 
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.lessons l
      JOIN public.course_sections cs ON l.section_id = cs.id
      JOIN public.courses c ON cs.course_id = c.id
      WHERE l.id = lesson_id AND c.instructor_id = auth.uid()
    )
  );

-- ── 6. TOPIC_FAQS — Teachers can manage ─────────────────────────
DROP POLICY IF EXISTS "Teachers can manage FAQs" ON public.topic_faqs;
CREATE POLICY "Teachers can manage FAQs" ON public.topic_faqs 
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.course_sections cs
      JOIN public.courses c ON c.id = cs.course_id
      WHERE cs.id = section_id AND c.instructor_id = auth.uid()
    )
  );

-- ── 7. COURSE_RESOURCES — Teachers can manage ───────────────────
DROP POLICY IF EXISTS "Teachers can manage resources" ON public.course_resources;
CREATE POLICY "Teachers can manage resources" ON public.course_resources 
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.courses c 
      WHERE c.id = course_id AND c.instructor_id = auth.uid()
    )
  );

-- ── 8. PROFILES — viewable ──────────────────────────────────────
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Profiles viewable by everyone" ON public.profiles;
CREATE POLICY "Profiles viewable by everyone" ON public.profiles 
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile" ON public.profiles 
  FOR UPDATE USING (auth.uid() = id);

-- Done! All core tables now have proper RLS policies.
