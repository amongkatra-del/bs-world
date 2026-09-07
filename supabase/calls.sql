-- Calling/signaling foundation. The actual media path must use WebRTC.
-- Never put a service-role key in the mobile app.

create table if not exists public.call_sessions (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid references public.conversations(id) on delete cascade,
  caller_id uuid references auth.users(id) on delete cascade,
  callee_id uuid references auth.users(id) on delete cascade,
  kind text not null check (kind in ('voice','video')),
  status text not null default 'ringing' check (status in ('ringing','accepted','declined','ended')),
  created_at timestamptz default now(),
  ended_at timestamptz
);

create table if not exists public.call_signals (
  id uuid primary key default gen_random_uuid(),
  call_id uuid references public.call_sessions(id) on delete cascade,
  sender_id uuid references auth.users(id) on delete cascade,
  signal_type text not null check (signal_type in ('offer','answer','ice','hangup')),
  payload jsonb not null,
  created_at timestamptz default now()
);

create index if not exists call_signals_call_created_idx
on public.call_signals(call_id, created_at);

alter table public.call_sessions enable row level security;
alter table public.call_signals enable row level security;

create policy "call participants can read sessions"
on public.call_sessions for select to authenticated
using (caller_id=auth.uid() or callee_id=auth.uid());

create policy "caller can create sessions"
on public.call_sessions for insert to authenticated
with check (caller_id=auth.uid());

create policy "participants can update sessions"
on public.call_sessions for update to authenticated
using (caller_id=auth.uid() or callee_id=auth.uid());

create policy "call participants can read signals"
on public.call_signals for select to authenticated
using (
  exists (
    select 1 from public.call_sessions c
    where c.id=call_signals.call_id
      and (c.caller_id=auth.uid() or c.callee_id=auth.uid())
  )
);

create policy "call participants can send signals"
on public.call_signals for insert to authenticated
with check (
  sender_id=auth.uid()
  and exists (
    select 1 from public.call_sessions c
    where c.id=call_signals.call_id
      and (c.caller_id=auth.uid() or c.callee_id=auth.uid())
  )
);

alter publication supabase_realtime add table public.call_sessions;
alter publication supabase_realtime add table public.call_signals;


-- Create a call session for the authenticated caller. The callee must be a member
-- of the same direct conversation. Returns the new call id.
create or replace function public.create_call_session(p_conversation_id uuid, p_callee_id uuid, p_kind text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  me uuid := auth.uid();
  cid uuid;
  new_id uuid;
begin
  if me is null then raise exception 'Not authenticated'; end if;
  if p_kind not in ('voice','video') then raise exception 'Invalid call type'; end if;
  if p_callee_id is null or p_callee_id = me then raise exception 'Invalid callee'; end if;
  select c.id into cid from conversations c
    where c.id=p_conversation_id and c.kind='direct'
      and exists(select 1 from conversation_members cm where cm.conversation_id=c.id and cm.user_id=me)
      and exists(select 1 from conversation_members cm where cm.conversation_id=c.id and cm.user_id=p_callee_id);
  if cid is null then raise exception 'Conversation access denied'; end if;
  insert into call_sessions(conversation_id,caller_id,callee_id,kind,status)
    values(cid,me,p_callee_id,p_kind,'ringing') returning id into new_id;
  return new_id;
end;
$$;
grant execute on function public.create_call_session(uuid,uuid,text) to authenticated;
