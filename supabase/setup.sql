-- bs.world FINAL ONE-TIME SUPABASE SETUP
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  display_name text not null,
  avatar_url text,
  bio text,
  last_seen timestamptz,
  created_at timestamptz default now()
);
create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  kind text not null default 'direct' check (kind in ('direct','group')),
  title text,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz default now()
);
create table if not exists public.conversation_members (
  conversation_id uuid references public.conversations(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  joined_at timestamptz default now(),
  primary key (conversation_id,user_id)
);
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid references public.conversations(id) on delete cascade,
  sender_id uuid references auth.users(id) on delete cascade,
  body text,
  message_type text not null default 'text',
  media_url text,
  created_at timestamptz default now(),
  read_at timestamptz
);
create table if not exists public.message_reads (
  message_id uuid references public.messages(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  read_at timestamptz default now(),
  primary key(message_id,user_id)
);
create table if not exists public.user_blocks (
  blocker_id uuid references auth.users(id) on delete cascade,
  blocked_id uuid references auth.users(id) on delete cascade,
  created_at timestamptz default now(),
  primary key(blocker_id,blocked_id),
  check(blocker_id<>blocked_id)
);
create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid references auth.users(id) on delete cascade,
  reported_id uuid references auth.users(id) on delete cascade,
  reason text not null,
  created_at timestamptz default now()
);
create table if not exists public.favorite_contacts (
  user_id uuid references auth.users(id) on delete cascade,
  contact_id uuid references auth.users(id) on delete cascade,
  created_at timestamptz default now(),
  primary key(user_id,contact_id), check(user_id<>contact_id)
);
create table if not exists public.call_sessions (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid references public.conversations(id) on delete cascade,
  caller_id uuid references auth.users(id) on delete cascade,
  callee_id uuid references auth.users(id) on delete cascade,
  kind text not null check(kind in('voice','video')),
  status text not null default 'ringing' check(status in('ringing','accepted','declined','ended')),
  created_at timestamptz default now(), ended_at timestamptz
);
create table if not exists public.call_signals (
  id uuid primary key default gen_random_uuid(),
  call_id uuid references public.call_sessions(id) on delete cascade,
  sender_id uuid references auth.users(id) on delete cascade,
  signal_type text not null check(signal_type in('offer','answer','ice','hangup')),
  payload jsonb not null,
  created_at timestamptz default now()
);
create index if not exists messages_conversation_created_idx on public.messages(conversation_id,created_at);
create index if not exists call_signals_call_created_idx on public.call_signals(call_id,created_at);

alter table public.profiles enable row level security;
alter table public.conversations enable row level security;
alter table public.conversation_members enable row level security;
alter table public.messages enable row level security;
alter table public.message_reads enable row level security;
alter table public.user_blocks enable row level security;
alter table public.reports enable row level security;
alter table public.favorite_contacts enable row level security;
alter table public.call_sessions enable row level security;
alter table public.call_signals enable row level security;

-- Re-runnable policies
DO $$ DECLARE r record; BEGIN
  FOR r IN SELECT schemaname,tablename,policyname FROM pg_policies WHERE schemaname='public' AND tablename IN ('profiles','conversations','conversation_members','messages','message_reads','user_blocks','reports','favorite_contacts','call_sessions','call_signals') LOOP
    EXECUTE format('drop policy if exists %I on %I.%I',r.policyname,r.schemaname,r.tablename);
  END LOOP;
END $$;

create policy profiles_read on public.profiles for select to authenticated using(true);
create policy profiles_insert on public.profiles for insert to authenticated with check(id=auth.uid());
create policy profiles_update on public.profiles for update to authenticated using(id=auth.uid()) with check(id=auth.uid());
create policy conversations_read on public.conversations for select to authenticated using(exists(select 1 from conversation_members cm where cm.conversation_id=id and cm.user_id=auth.uid()));
create policy members_read on public.conversation_members for select to authenticated using(user_id=auth.uid() or exists(select 1 from conversation_members x where x.conversation_id=conversation_members.conversation_id and x.user_id=auth.uid()));
create policy messages_read on public.messages for select to authenticated using(exists(select 1 from conversation_members cm where cm.conversation_id=messages.conversation_id and cm.user_id=auth.uid()));
create policy messages_insert on public.messages for insert to authenticated with check(sender_id=auth.uid() and exists(select 1 from conversation_members cm where cm.conversation_id=messages.conversation_id and cm.user_id=auth.uid()));
create policy messages_update on public.messages for update to authenticated using(exists(select 1 from conversation_members cm where cm.conversation_id=messages.conversation_id and cm.user_id=auth.uid()));
create policy reads_read on public.message_reads for select to authenticated using(user_id=auth.uid() or exists(select 1 from messages m join conversation_members cm on cm.conversation_id=m.conversation_id where m.id=message_id and cm.user_id=auth.uid()));
create policy reads_insert on public.message_reads for insert to authenticated with check(user_id=auth.uid());
create policy blocks_read on public.user_blocks for select to authenticated using(blocker_id=auth.uid());
create policy blocks_write on public.user_blocks for all to authenticated using(blocker_id=auth.uid()) with check(blocker_id=auth.uid());
create policy reports_insert on public.reports for insert to authenticated with check(reporter_id=auth.uid());
create policy favorites_all on public.favorite_contacts for all to authenticated using(user_id=auth.uid()) with check(user_id=auth.uid());
create policy calls_read on public.call_sessions for select to authenticated using(caller_id=auth.uid() or callee_id=auth.uid());
create policy calls_insert on public.call_sessions for insert to authenticated with check(caller_id=auth.uid());
create policy calls_update on public.call_sessions for update to authenticated using(caller_id=auth.uid() or callee_id=auth.uid());
create policy signals_read on public.call_signals for select to authenticated using(exists(select 1 from call_sessions c where c.id=call_id and (c.caller_id=auth.uid() or c.callee_id=auth.uid())));
create policy signals_insert on public.call_signals for insert to authenticated with check(sender_id=auth.uid() and exists(select 1 from call_sessions c where c.id=call_id and (c.caller_id=auth.uid() or c.callee_id=auth.uid())));

create or replace function public.get_or_create_direct_conversation(other_user uuid) returns uuid language plpgsql security definer set search_path=public as $$
declare me uuid:=auth.uid(); cid uuid; begin
 if me is null or other_user is null or other_user=me then raise exception 'Invalid contact'; end if;
 if exists(select 1 from user_blocks where blocker_id=me and blocked_id=other_user) or exists(select 1 from user_blocks where blocker_id=other_user and blocked_id=me) then raise exception 'This user is blocked'; end if;
 select c.id into cid from conversations c where c.kind='direct' and exists(select 1 from conversation_members where conversation_id=c.id and user_id=me) and exists(select 1 from conversation_members where conversation_id=c.id and user_id=other_user) and (select count(*) from conversation_members where conversation_id=c.id)=2 limit 1;
 if cid is null then insert into conversations(kind,created_by) values('direct',me) returning id into cid; insert into conversation_members values(cid,me,now()),(cid,other_user,now()); end if; return cid; end $$;
grant execute on function public.get_or_create_direct_conversation(uuid) to authenticated;

create or replace function public.create_group(p_title text,p_members uuid[]) returns uuid language plpgsql security definer set search_path=public as $$
declare me uuid:=auth.uid(); cid uuid; u uuid; begin if me is null or nullif(trim(p_title),'') is null then raise exception 'Group name required'; end if; insert into conversations(kind,title,created_by) values('group',trim(p_title),me) returning id into cid; insert into conversation_members values(cid,me,now()); foreach u in array coalesce(p_members,'{}'::uuid[]) loop if u is not null and u<>me then insert into conversation_members(conversation_id,user_id) values(cid,u) on conflict do nothing; end if; end loop; return cid; end $$;
grant execute on function public.create_group(text,uuid[]) to authenticated;

create or replace function public.get_my_chats() returns table(conversation_id uuid,kind text,title text,other_user_id uuid,other_username text,other_display_name text,other_avatar_url text,last_body text,last_message_type text,last_media_url text,last_created_at timestamptz,unread_count bigint) language sql security definer set search_path=public as $$
select c.id,c.kind,c.title,op.id,op.username,op.display_name,op.avatar_url,lm.body,lm.message_type,lm.media_url,lm.created_at,coalesce((select count(*) from messages um where um.conversation_id=c.id and um.sender_id<>auth.uid() and um.read_at is null),0)
from conversations c join conversation_members mine on mine.conversation_id=c.id and mine.user_id=auth.uid()
left join conversation_members other on other.conversation_id=c.id and other.user_id<>auth.uid()
left join profiles op on op.id=other.user_id
left join lateral(select m.body,m.message_type,m.media_url,m.created_at from messages m where m.conversation_id=c.id order by m.created_at desc limit 1) lm on true
order by coalesce(lm.created_at,c.created_at) desc; $$;
grant execute on function public.get_my_chats() to authenticated;

create or replace function public.mark_message_read(p_message_id uuid) returns void language plpgsql security definer set search_path=public as $$ declare cid uuid; begin select conversation_id into cid from messages where id=p_message_id; if cid is null or not exists(select 1 from conversation_members where conversation_id=cid and user_id=auth.uid()) then raise exception 'Not allowed'; end if; update messages set read_at=coalesce(read_at,now()) where id=p_message_id and sender_id<>auth.uid(); insert into message_reads(message_id,user_id) values(p_message_id,auth.uid()) on conflict do nothing; end $$;
grant execute on function public.mark_message_read(uuid) to authenticated;

create or replace function public.create_call_session(p_conversation_id uuid,p_callee_id uuid,p_kind text) returns uuid language plpgsql security definer set search_path=public as $$ declare me uuid:=auth.uid(); new_id uuid; begin if p_kind not in('voice','video') then raise exception 'Invalid call type'; end if; if not exists(select 1 from conversation_members where conversation_id=p_conversation_id and user_id=me) or not exists(select 1 from conversation_members where conversation_id=p_conversation_id and user_id=p_callee_id) then raise exception 'Conversation access denied'; end if; if exists(select 1 from user_blocks where blocker_id=me and blocked_id=p_callee_id) or exists(select 1 from user_blocks where blocker_id=p_callee_id and blocked_id=me) then raise exception 'This user is blocked'; end if; insert into call_sessions(conversation_id,caller_id,callee_id,kind) values(p_conversation_id,me,p_callee_id,p_kind) returning id into new_id; return new_id; end $$;
grant execute on function public.create_call_session(uuid,uuid,text) to authenticated;

insert into storage.buckets(id,name,public) values('chat-media','chat-media',false) on conflict(id) do nothing;
drop policy if exists chat_media_read on storage.objects;
drop policy if exists chat_media_upload on storage.objects;
create policy chat_media_read on storage.objects for select to authenticated using(bucket_id='chat-media' and exists(select 1 from conversation_members cm where cm.conversation_id=split_part(name,'/',1)::uuid and cm.user_id=auth.uid()));
create policy chat_media_upload on storage.objects for insert to authenticated with check(bucket_id='chat-media' and owner=auth.uid() and exists(select 1 from conversation_members cm where cm.conversation_id=split_part(name,'/',1)::uuid and cm.user_id=auth.uid()));

DO $$ BEGIN alter publication supabase_realtime add table public.messages; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN alter publication supabase_realtime add table public.message_reads; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN alter publication supabase_realtime add table public.call_sessions; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN alter publication supabase_realtime add table public.call_signals; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
