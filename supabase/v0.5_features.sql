-- bs.world v0.5: media, read receipts, presence support
alter table public.profiles add column if not exists last_seen timestamptz;
alter table public.messages add column if not exists read_at timestamptz;

create table if not exists public.message_reads (
  message_id uuid references public.messages(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  read_at timestamptz default now(),
  primary key(message_id,user_id)
);
alter table public.message_reads enable row level security;
drop policy if exists "members can read receipts" on public.message_reads;
drop policy if exists "users create own receipts" on public.message_reads;
create policy "members can read receipts" on public.message_reads for select to authenticated using (
  exists(select 1 from public.messages m join public.conversation_members cm on cm.conversation_id=m.conversation_id where m.id=message_reads.message_id and cm.user_id=auth.uid())
);
create policy "users create own receipts" on public.message_reads for insert to authenticated with check (user_id=auth.uid());

insert into storage.buckets (id,name,public) values ('chat-media','chat-media',false) on conflict (id) do nothing;
drop policy if exists "chat media read" on storage.objects;
drop policy if exists "chat media upload" on storage.objects;
create policy "chat media read" on storage.objects for select to authenticated using (bucket_id='chat-media');
create policy "chat media upload" on storage.objects for insert to authenticated with check (bucket_id='chat-media' and owner=auth.uid());

DO $$ BEGIN
  alter publication supabase_realtime add table public.message_reads;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
