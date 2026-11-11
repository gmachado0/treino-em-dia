-- Treino em Dia: cadastro restrito a convites de uso único.
-- Execute este arquivo no SQL Editor do Supabase.
-- A tabela não fica acessível pela API pública; apenas o trigger pode consultá-la.

create extension if not exists pgcrypto with schema extensions;

create table if not exists public.signup_invites (
  id uuid primary key default gen_random_uuid(),
  code_hash text not null unique,
  max_uses integer not null default 1 check (max_uses > 0),
  use_count integer not null default 0 check (use_count >= 0),
  expires_at timestamptz,
  revoked_at timestamptz,
  created_at timestamptz not null default now()
);

alter table public.signup_invites enable row level security;
revoke all on table public.signup_invites from anon, authenticated;

create or replace function public.enforce_invite_on_signup()
returns trigger
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_code text;
  v_invite_id uuid;
begin
  v_code := upper(trim(coalesce(new.raw_user_meta_data->>'invite_code', '')));

  if coalesce(new.raw_user_meta_data->>'is_adult', 'false') <> 'true' then
    raise exception 'AGE_RESTRICTED';
  end if;

  if v_code = '' then
    raise exception 'INVITE_REQUIRED';
  end if;

  select id
    into v_invite_id
    from public.signup_invites
   where code_hash = encode(extensions.digest(convert_to(v_code, 'UTF8'), 'sha256'), 'hex')
     and revoked_at is null
     and (expires_at is null or expires_at > now())
     and use_count < max_uses
   for update;

  if v_invite_id is null then
    raise exception 'INVITE_INVALID';
  end if;

  update public.signup_invites
     set use_count = use_count + 1
   where id = v_invite_id;

  new.raw_user_meta_data := coalesce(new.raw_user_meta_data, '{}'::jsonb) - 'invite_code';
  return new;
end;
$$;

drop trigger if exists enforce_invite_before_auth_user_insert on auth.users;
create trigger enforce_invite_before_auth_user_insert
before insert on auth.users
for each row execute function public.enforce_invite_on_signup();

-- Gere um convite de uso único válido por 7 dias.
-- Execute este bloco separadamente sempre que quiser criar um novo convite.
with generated as (
  select upper(encode(extensions.gen_random_bytes(16), 'hex')) as code
),
saved as (
  insert into public.signup_invites (code_hash, max_uses, expires_at)
  select
    encode(extensions.digest(convert_to(code, 'UTF8'), 'sha256'), 'hex'),
    1,
    now() + interval '7 days'
  from generated
  returning id
)
select generated.code as codigo_de_convite
from generated cross join saved;
