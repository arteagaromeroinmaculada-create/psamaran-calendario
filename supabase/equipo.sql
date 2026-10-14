-- Permite gestionar el equipo desde la pestaña «Equipo» de la app.
-- Pégalo entero en Supabase > SQL Editor y pulsa Run (una sola vez).
drop policy if exists "el equipo se ve a sí mismo" on public.team;
drop policy if exists "equipo ve equipo" on public.team;
drop policy if exists "equipo añade" on public.team;
drop policy if exists "equipo quita" on public.team;
create policy "equipo ve equipo" on public.team for select to authenticated using (public.is_team());
create policy "equipo añade"     on public.team for insert to authenticated with check (public.is_team());
create policy "equipo quita"     on public.team for delete to authenticated using (public.is_team());
grant select, insert, delete on public.team to authenticated;
