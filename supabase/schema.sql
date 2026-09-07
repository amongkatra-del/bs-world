-- bs.world v0.4 REAL CHAT BACKEND
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  display_name text not null,
  avatar_url text,
  bio text,
  created_at timestamptz default now()
);

create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  kind text not null default 'direct' check (kind in ('direct','group')),
  created_at timestamptz default now()
);

create table if not exists public.conversation_members (
  conversation_id uuid references public.conversations(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  joined_at timestamptz default now(),
  primary key (conversation_id, user_id)
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid references public.conversations(id) on delete cascade,
  sender_id uuid references auth.users(id) on delete cascade,
  body text,
  message_type text not null default 'text',
  media_url text,
  created_at timestamptz default now()
);

create index if not exists messages_conversation_created_idx on public.messages(conversation_id, created_at);

alter table public.profiles enable row level security;
alter table public.conversations enable row level security;
alter table public.conversation_members enable row level security;
alter table public.messages enable row level security;

-- Safe re-runnable policies
 drop policy if exists "profiles readable" on public.profiles;
 drop policy if exists "users create own profile" on public.profiles;
 drop policy if exists "users update own profile" on public.profiles;
 drop policy if exists "members can read memberships" on public.conversation_members;
 drop policy if exists "members can read messages" on public.messages;
 drop policy if exists "members can send messages" on public.messages;
 drop policy if exists "members can read conversations" on public.conversations;

create policy "profiles readable" on public.profiles for select to authenticated using (true);
create policy "users create own profile" on public.profiles for insert to authenticated with check (id = auth.uid());
create policy "users update own profile" on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());
create policy "members can read memberships" on public.conversation_members for select to authenticated using (user_id = auth.uid());
create policy "members can read conversations" on public.conversations for select to authenticated using (
  exists (select 1 from public.conversation_members cm where cm.conversation_id = conversations.id and cm.user_id = auth.uid())
);
create policy "members can read messages" on public.messages for select to authenticated using (
  exists (select 1 from public.conversation_members cm where cm.conversation_id = messages.conversation_id and cm.user_id = auth.uid())
);
create policy "members can send messages" on public.messages for insert to authenticated with check (
  sender_id = auth.uid() and exists (select 1 from public.conversation_members cm where cm.conversation_id = messages.conversation_id and cm.user_id = auth.uid())
);

-- Creates/reuses exactly one direct conversation for two users.
create or replace function public.get_or_create_direct_conversation(other_user uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  me uuid := auth.uid();
  cid uuid;
begin
  if me is null then raise exception 'Not authenticated'; end if;
  if other_user is null or other_user = me then raise exception 'Invalid contact'; end if;

  select c.id into cid
  from conversations c
  where c.kind='direct'
    and exists (select 1 from conversation_members a where a.conversation_id=c.id and a.user_id=me)
    and exists (select 1 from conversation_members b where b.conversation_id=c.id and b.user_id=other_user)
    and (select count(*) from conversation_members x where x.conversation_id=c.id)=2
  limit 1;

  if cid is null then
    insert into conversations(kind) values ('direct') returning id into cid;
    insert into conversation_members(conversation_id,user_id) values (cid,me),(cid,other_user);
  end if;
  return cid;
end;
$$;

grant execute on function public.get_or_create_direct_conversation(uuid) to authenticated;

-- Realtime
DO $$
BEGIN
  alter publication supabase_realtime add table public.messages;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
