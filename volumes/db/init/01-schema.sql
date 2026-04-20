-- ── Roller (supabase/postgres image bazılarını zaten oluşturur) ────────────
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon') THEN
    CREATE ROLE anon NOLOGIN NOINHERIT;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticated') THEN
    CREATE ROLE authenticated NOLOGIN NOINHERIT;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'service_role') THEN
    CREATE ROLE service_role NOLOGIN NOINHERIT BYPASSRLS;
  END IF;
END$$;

-- public şema izinleri
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT ALL ON TABLES    TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT ALL ON SEQUENCES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT ALL ON FUNCTIONS TO anon, authenticated, service_role;

-- ── Uygulama tablosu ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.quotes (
  id          bigserial    PRIMARY KEY,
  teklif_no   text         NOT NULL,
  tarih       timestamptz  NOT NULL,
  firma_adi   text         NOT NULL,
  items       jsonb        NOT NULL,
  kdv_dahil   boolean      NOT NULL DEFAULT false,
  kdv_orani   numeric      NOT NULL DEFAULT 0.2,
  created_at  timestamptz           DEFAULT now()
);

GRANT ALL ON TABLE    public.quotes         TO anon, authenticated, service_role;
GRANT ALL ON SEQUENCE public.quotes_id_seq  TO anon, authenticated, service_role;

ALTER TABLE public.quotes ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'quotes' AND policyname = 'public_all'
  ) THEN
    CREATE POLICY public_all ON public.quotes
      FOR ALL TO anon, authenticated, service_role
      USING (true) WITH CHECK (true);
  END IF;
END$$;
