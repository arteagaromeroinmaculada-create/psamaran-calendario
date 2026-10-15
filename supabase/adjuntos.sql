-- Adjuntos del calendario: carpeta privada «adjuntos» en Supabase Storage.
-- Pégalo entero en Supabase > SQL Editor y pulsa Run (una sola vez).
insert into storage.buckets (id, name, public, file_size_limit)
values ('adjuntos', 'adjuntos', false, 52428800)
on conflict (id) do update set public = false, file_size_limit = 52428800;

drop policy if exists "equipo ve adjuntos" on storage.objects;
drop policy if exists "equipo sube adjuntos" on storage.objects;
drop policy if exists "equipo cambia adjuntos" on storage.objects;
drop policy if exists "equipo borra adjuntos" on storage.objects;
create policy "equipo ve adjuntos"     on storage.objects for select to authenticated using (bucket_id = 'adjuntos' and public.is_team());
create policy "equipo sube adjuntos"   on storage.objects for insert to authenticated with check (bucket_id = 'adjuntos' and public.is_team());
create policy "equipo cambia adjuntos" on storage.objects for update to authenticated using (bucket_id = 'adjuntos' and public.is_team());
create policy "equipo borra adjuntos"  on storage.objects for delete to authenticated using (bucket_id = 'adjuntos' and public.is_team());
