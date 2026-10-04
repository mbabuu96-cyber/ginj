-- Алхам арилжааны тэмдэглэл — Supabase өгөгдлийн сангийн бүтэц
-- Supabase → SQL Editor → New query хэсэгт бүтнээр нь хуулж тавиад Run дарна.
-- Дахин ажиллуулахад аюулгүй (байгаа зүйлийг устгахгүй).

create table if not exists public.journal_docs (
  user_id    uuid        not null default auth.uid() references auth.users (id) on delete cascade,
  coll       text        not null check (coll in ('trades', 'days', 'reviews', 'beliefs', 'settings')),
  id         text        not null,
  data       jsonb       not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (user_id, coll, id)
);

-- Мөр бүрийн хамгаалалт: хэрэглэгч зөвхөн өөрийн өгөгдлийг харж, өөрчилнө.
alter table public.journal_docs enable row level security;

drop policy if exists "own rows: select" on public.journal_docs;
drop policy if exists "own rows: insert" on public.journal_docs;
drop policy if exists "own rows: update" on public.journal_docs;
drop policy if exists "own rows: delete" on public.journal_docs;

create policy "own rows: select" on public.journal_docs
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "own rows: insert" on public.journal_docs
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "own rows: update" on public.journal_docs
  for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "own rows: delete" on public.journal_docs
  for delete to authenticated using ((select auth.uid()) = user_id);

grant select, insert, update, delete on public.journal_docs to authenticated;
revoke all on public.journal_docs from anon;
