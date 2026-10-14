-- Calendario de marketing PSamarán: tablas y reglas de acceso.
-- Pégalo entero en Supabase > SQL Editor y pulsa Run.

-- Quién puede ver y editar el calendario (un email por persona)
create table if not exists public.team (
  email text primary key,
  added_at timestamptz not null default now()
);
alter table public.team enable row level security;
drop policy if exists "el equipo se ve a sí mismo" on public.team;
create policy "el equipo se ve a sí mismo" on public.team
  for select to authenticated using (lower(email) = lower(auth.jwt() ->> 'email'));

create or replace function public.is_team() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.team where lower(email) = lower(auth.jwt() ->> 'email'));
$$;

-- Todo el contenido: espectáculos (shows), tareas (items) y peticiones a artistas (requests)
create table if not exists public.docs (
  collection text not null,
  id text not null,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  updated_by text default (auth.jwt() ->> 'email'),
  primary key (collection, id)
);
alter table public.docs replica identity full;
alter table public.docs enable row level security;

drop policy if exists "equipo lee" on public.docs;
drop policy if exists "equipo crea" on public.docs;
drop policy if exists "equipo cambia" on public.docs;
drop policy if exists "equipo borra" on public.docs;
create policy "equipo lee"    on public.docs for select to authenticated using (public.is_team());
create policy "equipo crea"   on public.docs for insert to authenticated with check (public.is_team());
create policy "equipo cambia" on public.docs for update to authenticated using (public.is_team()) with check (public.is_team());
create policy "equipo borra"  on public.docs for delete to authenticated using (public.is_team());

create or replace function public.touch_docs() returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  new.updated_by := coalesce(auth.jwt() ->> 'email', new.updated_by);
  return new;
end $$;
drop trigger if exists docs_touch on public.docs;
create trigger docs_touch before insert or update on public.docs
  for each row execute function public.touch_docs();

-- Cambios en directo para todos los que tengan la app abierta
do $$ begin
  alter publication supabase_realtime add table public.docs;
exception when duplicate_object then null; end $$;

-- Añade aquí los emails del equipo (o desde Table Editor > team)
-- insert into public.team (email) values ('tu-email@ejemplo.com');
