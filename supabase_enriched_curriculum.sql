DO $$
DECLARE
    v_course_id UUID;
    sec_id UUID;
BEGIN
    -- 1. Find the Course (Updated to match your course title)
    SELECT id INTO v_course_id FROM public.courses WHERE title = 'Ravan Rasulov' LIMIT 1;

    IF v_course_id IS NULL THEN
        RAISE NOTICE 'Course not found. Please check your course title.';
        RETURN;
    END IF;

    -- Clear existing sections/lessons for this course (v_course_id resolves ambiguity)
    DELETE FROM public.course_sections WHERE course_id = v_course_id;

    -- SECTION 1: Giriş və Kursun Strukturu
    INSERT INTO public.course_sections (course_id, title, order_index)
    VALUES (v_course_id, 'Bölmə 1: Giriş və Kursun Strukturu', 1) RETURNING id INTO sec_id;
    INSERT INTO public.lessons (section_id, title, duration, order_index) VALUES 
    (sec_id, 'Xoş gəlmisiniz! Kursdan necə maksimum yararlanmalı?', '05:20', 1),
    (sec_id, 'Flutter və Dart-ın tarixi', '12:45', 2),
    (sec_id, 'Mühitinin qurulması (Windows/Mac)', '25:10', 3);

    -- SECTION 2: Dart Proqramlaşdırma Əsasları
    INSERT INTO public.course_sections (course_id, title, order_index)
    VALUES (v_course_id, 'Bölmə 2: Dart Proqramlaşdırma Əsasları', 2) RETURNING id INTO sec_id;
    INSERT INTO public.lessons (section_id, title, duration, order_index) VALUES 
    (sec_id, 'Dəyişənlər və Məlumat Tipləri', '18:30', 1),
    (sec_id, 'Operatorlar və Şərt Konstruksiyaları', '22:15', 2),
    (sec_id, 'Dövrlər (Loops) və Listlər', '28:40', 3);

    -- SECTION 3: Obyekt Yönümlü Proqramlaşdırma (OOP)
    INSERT INTO public.course_sections (course_id, title, order_index)
    VALUES (v_course_id, 'Bölmə 3: Obyekt Yönümlü Proqramlaşdırma (OOP)', 3) RETURNING id INTO sec_id;
    INSERT INTO public.lessons (section_id, title, duration, order_index) VALUES 
    (sec_id, 'Class və Object anlayışı', '35:00', 1),
    (sec_id, 'Inheritance (Varislik) və Abstraction', '42:20', 2),
    (sec_id, 'Mixins və Interfaces', '38:15', 3);

    -- SECTION 4: Flutter Widget Əsasları
    INSERT INTO public.course_sections (course_id, title, order_index)
    VALUES (v_course_id, 'Bölmə 4: Flutter Widget Əsasları', 4) RETURNING id INTO sec_id;
    INSERT INTO public.lessons (section_id, title, duration, order_index) VALUES 
    (sec_id, 'Stateless vs StatefulWidget', '20:10', 1),
    (sec_id, 'Scaffold və Temellər', '15:45', 2),
    (sec_id, 'Konteynerlər və Dekorasiya', '19:30', 3);

    -- SECTION 5: Layout və Dizayn
    INSERT INTO public.course_sections (course_id, title, order_index)
    VALUES (v_course_id, 'Bölmə 5: Layout və Dizayn', 5) RETURNING id INTO sec_id;
    INSERT INTO public.lessons (section_id, title, duration, order_index) VALUES 
    (sec_id, 'Row və Column ilə dərindən iş', '32:00', 1),
    (sec_id, 'Stack və Positioned istifadəsi', '25:40', 2),
    (sec_id, 'Responsive dizayn prinsipləri', '45:10', 3);

    -- SECTION 6: Naviqasiya və Marşrutlaşdırma
    INSERT INTO public.course_sections (course_id, title, order_index)
    VALUES (v_course_id, 'Bölmə 6: Naviqasiya və Marşrutlaşdırma', 6) RETURNING id INTO sec_id;
    INSERT INTO public.lessons (section_id, title, duration, order_index) VALUES 
    (sec_id, 'Navigator 1.0 Əsasları', '28:30', 1),
    (sec_id, 'GoRouter ilə Modern Naviqasiya', '40:15', 2),
    (sec_id, 'Deep Linking və Parametrlər', '35:00', 3);

    -- SECTION 7: State Management (Provider)
    INSERT INTO public.course_sections (course_id, title, order_index)
    VALUES (v_course_id, 'Bölmə 7: State Management (Provider)', 7) RETURNING id INTO sec_id;
    INSERT INTO public.lessons (section_id, title, duration, order_index) VALUES 
    (sec_id, 'ChangeNotifierProvider Giriş', '30:20', 1),
    (sec_id, 'Consumer və Selector optimizasiyası', '22:45', 2),
    (sec_id, 'Global State vs Local State', '25:10', 3);

    -- SECTION 8: Şəbəkə Sorğuları və API
    INSERT INTO public.course_sections (course_id, title, order_index)
    VALUES (v_course_id, 'Bölmə 8: Şəbəkə Sorğuları və API', 8) RETURNING id INTO sec_id;
    INSERT INTO public.lessons (section_id, title, duration, order_index) VALUES 
    (sec_id, 'Http vs Dio paketləri', '35:40', 1),
    (sec_id, 'JSON Parsing və Modelləşdirmə', '48:00', 2),
    (sec_id, 'Error Handling və Interceptors', '33:15', 3);

    -- SECTION 9: Supabase İnteqrasiyası
    INSERT INTO public.course_sections (course_id, title, order_index)
    VALUES (v_course_id, 'Bölmə 9: Supabase İnteqrasiyası', 9) RETURNING id INTO sec_id;
    INSERT INTO public.lessons (section_id, title, duration, order_index) VALUES 
    (sec_id, 'Supabase Auth və User Management', '45:00', 1),
    (sec_id, 'Real-time Database və Stream-lər', '38:30', 2),
    (sec_id, 'Storage və fayl yükləmələri', '29:45', 3);

    -- SECTION 10: Animasiyalar və Motion Design
    INSERT INTO public.course_sections (course_id, title, order_index)
    VALUES (v_course_id, 'Bölmə 10: Animasiyalar və Motion Design', 10) RETURNING id INTO sec_id;
    INSERT INTO public.lessons (section_id, title, duration, order_index) VALUES 
    (sec_id, 'Implicit Animations (AnimatedContainer)', '22:10', 1),
    (sec_id, 'Explicit Animations və Controller-lər', '55:20', 2),
    (sec_id, 'Custom Painter və Lottie', '42:15', 3);

    -- SECTION 11: Lokal Cache və Verilənlər Bazası
    INSERT INTO public.course_sections (course_id, title, order_index)
    VALUES (v_course_id, 'Bölmə 11: Lokal Cache və Verilənlər Bazası', 11) RETURNING id INTO sec_id;
    INSERT INTO public.lessons (section_id, title, duration, order_index) VALUES 
    (sec_id, 'SharedPreferences vs Hive', '30:00', 1),
    (sec_id, 'SQFlite ilə mürəkkəb sorğular', '45:45', 2),
    (sec_id, 'Offline-first tətbiq strategiyası', '38:20', 3);

    -- SECTION 12: Testləşdirmə (QA)
    INSERT INTO public.course_sections (course_id, title, order_index)
    VALUES (v_course_id, 'Bölmə 12: Testləşdirmə (QA)', 12) RETURNING id INTO sec_id;
    INSERT INTO public.lessons (section_id, title, duration, order_index) VALUES 
    (sec_id, 'Unit Testing (Məntiqin yoxlanması)', '25:40', 1),
    (sec_id, 'Widget Testing', '32:15', 2),
    (sec_id, 'Integration Testing', '50:10', 3);

    -- SECTION 13: Xüsusi Mövzular (Flavorlar, Firebase)
    INSERT INTO public.course_sections (course_id, title, order_index)
    VALUES (v_course_id, 'Bölmə 13: Xüsusi Mövzular', 13) RETURNING id INTO sec_id;
    INSERT INTO public.lessons (section_id, title, duration, order_index) VALUES 
    (sec_id, 'Flavor-lar (Dev, Stage, Prod)', '35:20', 1),
    (sec_id, 'Firebase Push Notifications', '48:30', 2),
    (sec_id, 'CI/CD (Codemagic, Github Actions)', '40:00', 3);

    -- SECTION 14: Layihə: Real E-Ticarət Tətbiqi
    INSERT INTO public.course_sections (course_id, title, order_index)
    VALUES (v_course_id, 'Bölmə 14: Layihə: Real E-Ticarət Tətbiqi', 14) RETURNING id INTO sec_id;
    INSERT INTO public.lessons (section_id, title, duration, order_index) VALUES 
    (sec_id, 'Memarlıq Seçimi (Clean Architecture)', '65:00', 1),
    (sec_id, 'Ödəniş sistemlərinin inteqrasiyası', '55:45', 2),
    (sec_id, 'Sifarişlərin izlənməsi modulunun qurulması', '72:30', 3);

    -- SECTION 15: App Store və Play Store-da Yayınlama
    INSERT INTO public.course_sections (course_id, title, order_index)
    VALUES (v_course_id, 'Bölmə 15: Yayınlama və Marketing', 15) RETURNING id INTO sec_id;
    INSERT INTO public.lessons (section_id, title, duration, order_index) VALUES 
    (sec_id, 'Google Play Store qaydaları', '30:20', 1),
    (sec_id, 'App Store-a tətbiq göndərmək', '45:10', 2),
    (sec_id, 'ASO (App Store Optimization) Əsasları', '28:45', 3),
    (sec_id, 'Kursun sonu: Növbəti addımlar', '15:20', 4);

END $$;
