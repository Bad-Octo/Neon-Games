-- Exécuter dans Supabase > SQL Editor > New query.
-- Démo communautaire avec scores déclarés par les navigateurs.
-- L'absence de vérification côté serveur signifie que les scores peuvent être falsifiés.
create table if not exists public.neon_scores (
  id bigint generated always as identity primary key,
  game_id text not null check (game_id ~ '^[a-z0-9-]{2,50}$'),
  initials text not null check (initials ~ '^[A-Z]{3}$'),
  score integer not null check (score between 0 and 999999999),
  created_at timestamptz not null default now()
);
create index if not exists neon_scores_order on public.neon_scores (game_id, score, created_at);
alter table public.neon_scores enable row level security;
revoke all on public.neon_scores from public, anon, authenticated;
grant select, insert on public.neon_scores to anon, authenticated;
drop policy if exists neon_scores_read on public.neon_scores;
create policy neon_scores_read on public.neon_scores for select to anon, authenticated using (true);
drop policy if exists neon_scores_add on public.neon_scores;
create policy neon_scores_add on public.neon_scores for insert to anon, authenticated with check (true);
-- Ne jamais mettre la clé secrète/service_role dans le HTML public.
-- Pour limiter la triche et le spam, ajouter ultérieurement une Edge Function
-- avec vérification des parties, protection anti-abus et limites de fréquence.
