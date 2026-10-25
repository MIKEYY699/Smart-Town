-- FCM tokens for push notifications. One row per phone.
create table if not exists public.device_tokens (
  token text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  platform text not null,
  updated_at timestamptz not null default now()
);

create index if not exists device_tokens_user_id_idx
  on public.device_tokens (user_id);

alter table public.device_tokens enable row level security;

create policy "Users see their own tokens"
  on public.device_tokens for select
  using (auth.uid() = user_id);

create policy "Users delete their own tokens"
  on public.device_tokens for delete
  using (auth.uid() = user_id);

-- Saving goes through this function so that a phone which changes hands
-- (another user logs in on it) moves to the new user. A plain upsert would
-- be blocked by RLS because the old row belongs to someone else.
create or replace function public.register_device_token(
  p_token text,
  p_platform text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'Not logged in';
  end if;

  insert into public.device_tokens (token, user_id, platform, updated_at)
  values (p_token, auth.uid(), p_platform, now())
  on conflict (token) do update
    set user_id = excluded.user_id,
        platform = excluded.platform,
        updated_at = now();
end;
$$;

revoke all on function public.register_device_token(text, text) from public, anon;
grant execute on function public.register_device_token(text, text) to authenticated;
