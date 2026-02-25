-- ============================================================
-- AI DOCUMENT PROCESSING — SUPABASE SCHEMA MIGRATION
-- ============================================================
-- Run this in Supabase SQL Editor or via `supabase db push`
-- ============================================================

-- 0. Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- for full-text search

-- ============================================================
-- 1. ai_documents — Uploaded file metadata
-- ============================================================
CREATE TABLE IF NOT EXISTS public.ai_documents (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    file_name TEXT NOT NULL,
    file_type TEXT NOT NULL CHECK (file_type IN ('pdf', 'image', 'audio')),
    file_size_bytes BIGINT NOT NULL DEFAULT 0,
    storage_path TEXT NOT NULL,
    mime_type TEXT,
    page_count INT DEFAULT 0,
    language TEXT DEFAULT 'az',
    status TEXT NOT NULL DEFAULT 'uploaded'
        CHECK (status IN ('uploaded', 'processing', 'polling', 'draft', 'published', 'failed')),
    published_at TIMESTAMPTZ,
    active_version INT DEFAULT 1,
    content_hash TEXT, -- SHA-256 for deduplication
    metadata JSONB DEFAULT '{}',
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_documents_user_id ON public.ai_documents(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_documents_status ON public.ai_documents(status);
CREATE INDEX IF NOT EXISTS idx_ai_documents_content_hash ON public.ai_documents(content_hash);

-- ============================================================
-- 2. ai_document_pages — Per-page extracted text
-- ============================================================
CREATE TABLE IF NOT EXISTS public.ai_document_pages (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    document_id UUID NOT NULL REFERENCES public.ai_documents(id) ON DELETE CASCADE,
    page_no INT NOT NULL,
    
    -- Processing Stages
    raw_text TEXT,                    -- Raw OCR text
    clean_text TEXT,                  -- Processed text (Groq cleaned or Native)
    cleaning_model TEXT,              -- E.g., 'llama-3.3-70b-versatile'
    cleaning_version TEXT DEFAULT 'v1',
    cleaning_failed BOOLEAN DEFAULT FALSE,
    changes_summary TEXT,             -- What Groq fixed
    
    -- Teacher Edit Stage
    edited_text TEXT,
    edited_by UUID REFERENCES auth.users(id),
    edited_at TIMESTAMPTZ,
    
    source TEXT NOT NULL DEFAULT 'native'
        CHECK (source IN ('native', 'ocr')),
    confidence REAL, -- OCR confidence 0.0-1.0
    bbox JSONB, -- optional bounding boxes
    word_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(document_id, page_no)
);

CREATE INDEX IF NOT EXISTS idx_ai_doc_pages_document ON public.ai_document_pages(document_id);
-- No full-text search index on raw/cleaned yet as the versions snapshot is what we use primarily

-- ============================================================
-- 2B. ai_document_versions — Immutable Published Snapshots
-- ============================================================
CREATE TABLE IF NOT EXISTS ai_document_versions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID REFERENCES ai_documents(id) ON DELETE CASCADE,
    version INT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id),
    snapshot_json JSONB NOT NULL,
    publish_notes TEXT
);

CREATE INDEX IF NOT EXISTS idx_ai_doc_versions_doc_id ON ai_document_versions (document_id);

ALTER TABLE ai_document_versions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can insert their own versions" ON ai_document_versions FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Users can view their own versions" ON ai_document_versions FOR SELECT USING (auth.uid() = created_by);

-- ============================================================
-- 3. ai_document_chunks — Semantic chunks for LLM
-- ============================================================
CREATE TABLE IF NOT EXISTS public.ai_document_chunks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    document_id UUID NOT NULL REFERENCES public.ai_documents(id) ON DELETE CASCADE,
    chunk_index INT NOT NULL,
    page_start INT NOT NULL,
    page_end INT NOT NULL,
    text TEXT NOT NULL,
    token_estimate INT DEFAULT 0,
    content_hash TEXT, -- for caching/dedup
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(document_id, chunk_index)
);

CREATE INDEX IF NOT EXISTS idx_ai_doc_chunks_document ON public.ai_document_chunks(document_id);
CREATE INDEX IF NOT EXISTS idx_ai_doc_chunks_hash ON public.ai_document_chunks(content_hash);

-- ============================================================
-- 4. ai_transcripts — Audio transcriptions
-- ============================================================
CREATE TABLE IF NOT EXISTS public.ai_transcripts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    document_id UUID REFERENCES public.ai_documents(id) ON DELETE SET NULL,
    title TEXT NOT NULL DEFAULT 'Səs yazısı',
    storage_path TEXT NOT NULL,
    duration_seconds REAL,
    language TEXT DEFAULT 'az',
    full_text TEXT NOT NULL DEFAULT '',
    segments JSONB DEFAULT '[]', -- [{start, end, text}]
    word_count INT DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_transcripts_user ON public.ai_transcripts(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_transcripts_status ON public.ai_transcripts(status);

-- ============================================================
-- 5. ai_questions — Generated questions
-- ============================================================
CREATE TABLE IF NOT EXISTS public.ai_questions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    document_id UUID REFERENCES public.ai_documents(id) ON DELETE SET NULL,
    transcript_id UUID REFERENCES public.ai_transcripts(id) ON DELETE SET NULL,
    question_type TEXT NOT NULL DEFAULT 'mcq'
        CHECK (question_type IN ('mcq', 'open_ended', 'true_false', 'fill_in_blank')),
    question_text TEXT NOT NULL,
    options JSONB, -- for MCQ: ["A","B","C","D"]
    answer_key TEXT, -- correct answer
    correct_index INT, -- for MCQ
    difficulty TEXT DEFAULT 'medium'
        CHECK (difficulty IN ('easy', 'medium', 'hard')),
    source_page_start INT,
    source_page_end INT,
    source_text_hash TEXT, -- to avoid duplicate generation
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_questions_document ON public.ai_questions(document_id);
CREATE INDEX IF NOT EXISTS idx_ai_questions_transcript ON public.ai_questions(transcript_id);
CREATE INDEX IF NOT EXISTS idx_ai_questions_user ON public.ai_questions(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_questions_type ON public.ai_questions(question_type);
CREATE INDEX IF NOT EXISTS idx_ai_questions_hash ON public.ai_questions(source_text_hash);

-- ============================================================
-- 6. ai_jobs — Async job queue
-- ============================================================
CREATE TABLE IF NOT EXISTS public.ai_jobs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    job_type TEXT NOT NULL
        CHECK (job_type IN (
            'pdf_extract', 'image_ocr', 'audio_stt',
            'question_gen', 'summarize', 'export', 'generate_questions'
        )),
    status TEXT NOT NULL DEFAULT 'queued'
        CHECK (status IN ('queued', 'running', 'polling', 'completed', 'failed', 'cancelled')),
    -- Progress tracking
    total_steps INT DEFAULT 0,
    done_steps INT DEFAULT 0,
    percent REAL DEFAULT 0.0,
    current_step TEXT, -- human-readable: "OCR: Səhifə 3/10"
    -- Reference IDs
    document_id UUID REFERENCES public.ai_documents(id) ON DELETE SET NULL,
    transcript_id UUID REFERENCES public.ai_transcripts(id) ON DELETE SET NULL,
    -- Input params
    params JSONB DEFAULT '{}',
    -- Result
    result JSONB,
    error_message TEXT,
    -- Retry / watchdog
    retry_count INT DEFAULT 0,
    max_retries INT DEFAULT 3,
    heartbeat_at TIMESTAMPTZ,
    last_heartbeat_at TIMESTAMPTZ,
    operation_name TEXT,
    cleanup_failed BOOLEAN DEFAULT FALSE,
    timeout_at TIMESTAMPTZ,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_jobs_status ON public.ai_jobs(status);
CREATE INDEX IF NOT EXISTS idx_ai_jobs_user ON public.ai_jobs(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_jobs_type ON public.ai_jobs(job_type);
CREATE INDEX IF NOT EXISTS idx_ai_jobs_heartbeat ON public.ai_jobs(heartbeat_at)
    WHERE status = 'running';

-- ============================================================
-- 7. ai_job_events — Job event log / observability
-- ============================================================
CREATE TABLE IF NOT EXISTS public.ai_job_events (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    job_id UUID NOT NULL REFERENCES public.ai_jobs(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL
        CHECK (event_type IN ('info', 'warning', 'error', 'progress', 'retry', 'timeout')),
    step TEXT,
    message TEXT,
    error_stack TEXT,
    duration_ms INT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_job_events_job ON public.ai_job_events(job_id);
CREATE INDEX IF NOT EXISTS idx_ai_job_events_type ON public.ai_job_events(event_type);

-- ============================================================
-- 8. ai_exports — Generated export files
-- ============================================================
CREATE TABLE IF NOT EXISTS public.ai_exports (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    source_type TEXT NOT NULL
        CHECK (source_type IN ('document', 'transcript', 'questions')),
    source_id UUID NOT NULL,
    format TEXT NOT NULL CHECK (format IN ('pdf', 'docx')),
    storage_path TEXT NOT NULL,
    file_name TEXT NOT NULL,
    file_size_bytes BIGINT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_exports_user ON public.ai_exports(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_exports_source ON public.ai_exports(source_type, source_id);

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================

-- ai_documents
ALTER TABLE public.ai_documents ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own documents" ON public.ai_documents;
CREATE POLICY "Users can view own documents" ON public.ai_documents
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own documents" ON public.ai_documents;
CREATE POLICY "Users can insert own documents" ON public.ai_documents
    FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own documents" ON public.ai_documents;
CREATE POLICY "Users can update own documents" ON public.ai_documents
    FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own documents" ON public.ai_documents;
CREATE POLICY "Users can delete own documents" ON public.ai_documents
    FOR DELETE USING (auth.uid() = user_id);

-- ai_document_pages
ALTER TABLE public.ai_document_pages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own doc pages" ON public.ai_document_pages;
CREATE POLICY "Users can view own doc pages" ON public.ai_document_pages
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.ai_documents WHERE id = document_id AND user_id = auth.uid())
    );

DROP POLICY IF EXISTS "Service can manage doc pages" ON public.ai_document_pages;
CREATE POLICY "Service can manage doc pages" ON public.ai_document_pages
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.ai_documents WHERE id = document_id AND user_id = auth.uid())
    );

-- ai_document_chunks
ALTER TABLE public.ai_document_chunks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own chunks" ON public.ai_document_chunks;
CREATE POLICY "Users can view own chunks" ON public.ai_document_chunks
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.ai_documents WHERE id = document_id AND user_id = auth.uid())
    );

DROP POLICY IF EXISTS "Service can manage chunks" ON public.ai_document_chunks;
CREATE POLICY "Service can manage chunks" ON public.ai_document_chunks
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.ai_documents WHERE id = document_id AND user_id = auth.uid())
    );

-- ai_transcripts
ALTER TABLE public.ai_transcripts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can CRUD own transcripts" ON public.ai_transcripts;
CREATE POLICY "Users can CRUD own transcripts" ON public.ai_transcripts
    FOR ALL USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ai_questions
ALTER TABLE public.ai_questions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can CRUD own questions" ON public.ai_questions;
CREATE POLICY "Users can CRUD own questions" ON public.ai_questions
    FOR ALL USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ai_jobs
ALTER TABLE public.ai_jobs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own jobs" ON public.ai_jobs;
CREATE POLICY "Users can view own jobs" ON public.ai_jobs
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own jobs" ON public.ai_jobs;
CREATE POLICY "Users can insert own jobs" ON public.ai_jobs
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ai_job_events (read-only for users through jobs)
ALTER TABLE public.ai_job_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own job events" ON public.ai_job_events;
CREATE POLICY "Users can view own job events" ON public.ai_job_events
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.ai_jobs WHERE id = job_id AND user_id = auth.uid())
    );

-- ai_exports
ALTER TABLE public.ai_exports ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can CRUD own exports" ON public.ai_exports;
CREATE POLICY "Users can CRUD own exports" ON public.ai_exports
    FOR ALL USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- STORAGE BUCKETS (run in Supabase Dashboard or SQL)
-- ============================================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  ('ai-uploads', 'ai-uploads', false, 157286400, -- 150MB
   ARRAY['application/pdf','image/jpeg','image/png','image/heic','image/webp',
         'audio/mpeg','audio/wav','audio/mp4','audio/ogg','audio/webm']),
  ('ai-exports', 'ai-exports', false, 52428800, -- 50MB
   ARRAY['application/pdf','application/vnd.openxmlformats-officedocument.wordprocessingml.document'])
ON CONFLICT (id) DO UPDATE SET 
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Storage RLS (ai-uploads)
DROP POLICY IF EXISTS "Users upload own files" ON storage.objects;
CREATE POLICY "Users upload own files" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'ai-uploads' AND (storage.foldername(name))[1] = auth.uid()::text);

DROP POLICY IF EXISTS "Users read own files" ON storage.objects;
CREATE POLICY "Users read own files" ON storage.objects
  FOR SELECT TO authenticated
  USING (bucket_id = 'ai-uploads' AND (storage.foldername(name))[1] = auth.uid()::text);

DROP POLICY IF EXISTS "Users update own files" ON storage.objects;
CREATE POLICY "Users update own files" ON storage.objects
  FOR UPDATE TO authenticated
  USING (bucket_id = 'ai-uploads' AND (storage.foldername(name))[1] = auth.uid()::text);

DROP POLICY IF EXISTS "Users delete own files" ON storage.objects;
CREATE POLICY "Users delete own files" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'ai-uploads' AND (storage.foldername(name))[1] = auth.uid()::text);

-- Storage RLS (ai-exports)
DROP POLICY IF EXISTS "Users read own exports" ON storage.objects;
CREATE POLICY "Users read own exports" ON storage.objects
  FOR SELECT TO authenticated
  USING (bucket_id = 'ai-exports' AND (storage.foldername(name))[1] = auth.uid()::text);

DROP POLICY IF EXISTS "Users delete own exports" ON storage.objects;
CREATE POLICY "Users delete own exports" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'ai-exports' AND (storage.foldername(name))[1] = auth.uid()::text);

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION public.ai_update_timestamp()
RETURNS trigger AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ai_documents_updated
    BEFORE UPDATE ON public.ai_documents
    FOR EACH ROW EXECUTE FUNCTION public.ai_update_timestamp();

CREATE TRIGGER ai_transcripts_updated
    BEFORE UPDATE ON public.ai_transcripts
    FOR EACH ROW EXECUTE FUNCTION public.ai_update_timestamp();

CREATE TRIGGER ai_jobs_updated
    BEFORE UPDATE ON public.ai_jobs
    FOR EACH ROW EXECUTE FUNCTION public.ai_update_timestamp();

-- Claim next queued job (atomic)
CREATE OR REPLACE FUNCTION public.claim_next_job(p_job_type TEXT DEFAULT NULL)
RETURNS UUID AS $$
DECLARE
    v_job_id UUID;
BEGIN
    SELECT id INTO v_job_id
    FROM public.ai_jobs
    WHERE status = 'queued'
      AND (p_job_type IS NULL OR job_type = p_job_type)
    ORDER BY created_at ASC
    LIMIT 1
    FOR UPDATE SKIP LOCKED;

    IF v_job_id IS NOT NULL THEN
        UPDATE public.ai_jobs
        SET status = 'running',
            started_at = NOW(),
            heartbeat_at = NOW(),
            timeout_at = NOW() + INTERVAL '10 minutes'
        WHERE id = v_job_id;
    END IF;

    RETURN v_job_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Timeout stale jobs
CREATE OR REPLACE FUNCTION public.timeout_stale_jobs()
RETURNS INT AS $$
DECLARE
    v_count INT;
BEGIN
    UPDATE public.ai_jobs
    SET status = 'failed',
        error_message = 'Job timed out (no heartbeat)',
        completed_at = NOW()
    WHERE status = 'running'
      AND (
          (heartbeat_at IS NOT NULL AND heartbeat_at < NOW() - INTERVAL '2 minutes')
          OR
          (timeout_at IS NOT NULL AND timeout_at < NOW())
      );

    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
