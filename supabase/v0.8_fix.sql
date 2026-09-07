-- bs.world v0.8 fixes: real chat list + incoming calls
create or replace function public.get_my_direct_chats()
returns table(
  conversation_id uuid,
  other_user_id uuid,
  other_username text,
  other_display_name text,
  other_avatar_url text,
  last_body text,
  last_message_type text,
  last_media_url text,
  last_created_at timestamptz,
  unread_count bigint
)
language sql
security definer
set search_path = public
as $$
  select c.id,
         p.id,
         p.username,
         p.display_name,
         p.avatar_url,
         lm.body,
         lm.message_type,
         lm.media_url,
         lm.created_at,
         coalesce((select count(*) from messages um where um.conversation_id=c.id and um.sender_id<>auth.uid() and um.read_at is null),0)
  from conversations c
  join conversation_members mine on mine.conversation_id=c.id and mine.user_id=auth.uid()
  join conversation_members other on other.conversation_id=c.id and other.user_id<>auth.uid()
  join profiles p on p.id=other.user_id
  left join lateral (
    select m.body,m.message_type,m.media_url,m.created_at
    from messages m where m.conversation_id=c.id order by m.created_at desc limit 1
  ) lm on true
  where c.kind='direct'
  order by coalesce(lm.created_at,c.created_at) desc;
$$;
grant execute on function public.get_my_direct_chats() to authenticated;

-- Atomic read marker helper.
create or replace function public.mark_message_read(p_message_id uuid)
returns void language plpgsql security definer set search_path=public as $$
declare cid uuid;
begin
  select conversation_id into cid from messages where id=p_message_id;
  if cid is null or not exists(select 1 from conversation_members where conversation_id=cid and user_id=auth.uid()) then
    raise exception 'Not allowed';
  end if;
  update messages set read_at=coalesce(read_at,now()) where id=p_message_id and sender_id<>auth.uid();
  insert into message_reads(message_id,user_id) values(p_message_id,auth.uid()) on conflict do nothing;
end; $$;
grant execute on function public.mark_message_read(uuid) to authenticated;
