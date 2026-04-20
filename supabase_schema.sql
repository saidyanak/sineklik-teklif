-- Supabase dashboard > SQL Editor'da çalıştırın

create table public.quotes (
  id          bigserial primary key,
  teklif_no   text        not null,
  tarih       timestamptz not null,
  firma_adi   text        not null,
  items       jsonb       not null,
  kdv_dahil   boolean     not null default false,
  kdv_orani   numeric     not null default 0.2,
  created_at  timestamptz          default now()
);

-- Dahili uygulama için public erişim (RLS açık ama herkese izin)
alter table public.quotes enable row level security;

create policy "public_all" on public.quotes
  for all
  to anon, authenticated
  using (true)
  with check (true);
