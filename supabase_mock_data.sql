-- EDUCOMPANY ENHANCED MOCK DATA SCRIPT

-- 1. Full Categories List
INSERT INTO public.categories (name) VALUES 
('Mobil İnkişaf'),
('Dizayn'),
('Kompüter Elmləri'),
('Marketing'),
('Data Science'),
('Biznes'),
('Xarici Dillər')
ON CONFLICT (name) DO NOTHING;

-- 2. Detailed Courses and Modules
DO $$
DECLARE
    cat_mobile_id UUID;
    cat_design_id UUID;
    cat_cs_id UUID;
    cat_marketing_id UUID;
    course_f_id UUID;
    course_d_id UUID;
    course_a_id UUID;
    course_m_id UUID;
    sec_id UUID;
BEGIN
    -- Get category IDs
    SELECT id INTO cat_mobile_id FROM public.categories WHERE name = 'Mobil İnkişaf';
    SELECT id INTO cat_design_id FROM public.categories WHERE name = 'Dizayn';
    SELECT id INTO cat_cs_id FROM public.categories WHERE name = 'Kompüter Elmləri';
    SELECT id INTO cat_marketing_id FROM public.categories WHERE name = 'Marketing';

    -- ---------------------------------------------------------
    -- COURSE 1: Flutter İnkişafı Masterklas (Live + Video)
    -- ---------------------------------------------------------
    INSERT INTO public.courses (title, description, category_id, rating, students_count, is_live, thumbnail_url)
    VALUES ('Flutter İnkişafı Masterklas', 'Flutter və Dart ilə peşəkar mobil tətbiqlər qurun.', cat_mobile_id, 4.9, 1450, true, 'https://picsum.photos/seed/flutter/800/600')
    RETURNING id INTO course_f_id;

    -- Section 1: Giriş
    INSERT INTO public.course_sections (course_id, title, order_index)
    VALUES (course_f_id, 'Kursun Strukturu və Giriş', 1) RETURNING id INTO sec_id;
    
    INSERT INTO public.lessons (section_id, title, duration, order_index, gumlet_asset_id)
    VALUES 
    (sec_id, 'Platformaya xoş gəlmisiniz', '05:20', 1, '64f1a2b3c4d5e6f1'),
    (sec_id, 'Flutter nədir?', '12:45', 2, '64f1a2b3c4d5e6f2'),
    (sec_id, 'Native vs Hybrid yanaşma', '15:10', 3, '64f1a2b3c4d5e6f3');

    -- Section 2: Dart Proqramlaşdırma
    INSERT INTO public.course_sections (course_id, title, order_index)
    VALUES (course_f_id, 'Dart Proqramlaşdırma Dili', 2) RETURNING id INTO sec_id;

    INSERT INTO public.lessons (section_id, title, duration, order_index, gumlet_asset_id)
    VALUES 
    (sec_id, 'Dəyişənlər və Məlumat Tipləri', '25:30', 1, '64f1a2b3c4d5e6f4'),
    (sec_id, 'Funksiyalar və OOP Əsasları', '45:00', 2, '64f1a2b3c4d5e6f5'),
    (sec_id, 'Asinxron Proqramlaşdırma (Async/Await)', '35:20', 3, '64f1a2b3c4d5e6f6');

    -- ---------------------------------------------------------
    -- COURSE 2: Python ilə Süni İntellekt (Video Course)
    -- ---------------------------------------------------------
    INSERT INTO public.courses (title, description, category_id, rating, students_count, is_live, thumbnail_url)
    VALUES ('Python ilə Süni İntellekt', 'AI və Machine Learning dünyasına ilk addım.', cat_cs_id, 4.7, 3200, false, 'https://picsum.photos/seed/ai/800/600')
    RETURNING id INTO course_a_id;

    -- Section 1: Giriş
    INSERT INTO public.course_sections (course_id, title, order_index)
    VALUES (course_a_id, 'Süni İntellektə Giriş', 1) RETURNING id INTO sec_id;

    INSERT INTO public.lessons (section_id, title, duration, order_index, gumlet_asset_id)
    VALUES 
    (sec_id, 'AI-ın tarixi və gələcəyi', '10:00', 1, '64f1a2b3c4d5e6f7'),
    (sec_id, 'Model təlimi nədir?', '22:15', 2, '64f1a2b3c4d5e6f8');

    -- ---------------------------------------------------------
    -- COURSE 3: Rəqəmsal Marketinq (Video Course)
    -- ---------------------------------------------------------
    INSERT INTO public.courses (title, description, category_id, rating, students_count, is_live, thumbnail_url)
    VALUES ('Digital Marketing Strategiyaları', 'Brendinizi böyütmək üçün müasir marketinq alətləri.', cat_marketing_id, 4.6, 1200, false, 'https://picsum.photos/seed/market/800/600')
    RETURNING id INTO course_m_id;

    INSERT INTO public.course_sections (course_id, title, order_index)
    VALUES (course_m_id, 'Sosial Media Marketinq', 1) RETURNING id INTO sec_id;

    INSERT INTO public.lessons (section_id, title, duration, order_index, gumlet_asset_id)
    VALUES 
    (sec_id, 'SMM Əsasları', '15:40', 1, '64f1a2b3c4d5e6f9'),
    (sec_id, 'Targeting necə qurulur?', '30:20', 2, '64f1a2b3c4d5e6f10');

    -- ---------------------------------------------------------
    -- EXAMS & ASSIGNMENTS
    -- ---------------------------------------------------------
    INSERT INTO public.assignments (course_id, title, description, deadline)
    VALUES 
    (course_f_id, 'Todo Tətbiqi Qurun', 'Provider istifadə edərək tam funksional tətbiq yaradın.', now() + interval '5 days'),
    (course_a_id, 'Regressiya Modeli Hazırlayın', 'Verilmiş data üzərində xətti regressiya qurun.', now() + interval '10 days');

    INSERT INTO public.exams (course_id, title, duration_minutes)
    VALUES (course_f_id, 'Flutter Əsasları İmtahanı', 45)
    RETURNING id INTO sec_id;

    INSERT INTO public.exam_questions (exam_id, question, options, correct_index)
    VALUES 
    (sec_id, 'Flutter-da bütün widget-lər üçün əsas klass hansıdır?', ARRAY['Widget', 'Component', 'View', 'Element'], 0),
    (sec_id, 'Vəziyyət dəyişdikdə hansı widget yenidən qurulur?', ARRAY['StatelessWidget', 'StatefulWidget', 'InheritedWidget', 'Container'], 1),
    (sec_id, 'Dart dilində asinxron funksiya hansı keyword ilə başlayır?', ARRAY['await', 'async', 'future', 'void'], 1);

END $$;
