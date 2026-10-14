# Calendario de marketing PSamarán

Calendario compartido de funciones, publicaciones de artistas, campañas y material de PSamarán y Sala Tabor.

- **Web estática** (`index.html`), sin compilación. Se publica tal cual en Vercel.
- **Supabase** para el login por enlace de email y para guardar los datos.
- Solo entra quien esté en la tabla `team` de Supabase.

## Puesta en marcha (una sola vez)

### 1. Supabase
1. En supabase.com, crea un proyecto nuevo (región: Europa).
2. Ve a **SQL Editor**, pega el contenido de `supabase/schema.sql` y pulsa **Run**.
3. Haz lo mismo con `supabase/seed.sql` para cargar los espectáculos y tareas actuales.
4. En **Table Editor > team**, añade una fila con cada email que deba entrar.
5. En **Project Settings > API**, copia la **Project URL** y la clave **anon public**. Van en `config.js`.

### 2. Vercel
1. En vercel.com, pulsa **Add New > Project** e importa este repositorio.
2. Framework: **Other**. No hace falta comando de build. Pulsa **Deploy**.
3. Copia la dirección que te da (por ejemplo `psamaran-calendario.vercel.app`).

### 3. Conectar las dos cosas
En Supabase, **Authentication > URL Configuration**:
- **Site URL**: la dirección de Vercel.
- **Redirect URLs**: añade la misma dirección.

## Día a día

- **Dar acceso a alguien**: añade su email en la tabla `team` de Supabase. Entra escribiendo su email en la app y abriendo el enlace que le llega.
- **Quitar acceso**: borra su fila de `team`.

## Estructura de datos

Todo vive en la tabla `docs` (`collection`, `id`, `data`):
- `shows`: espectáculos (name, artist, date, time, venue, audience, notes).
- `items`: tareas del calendario (type publicacion/campana/material/tarea, title, show, date, time, status pendiente/curso/hecho/bloqueado, owner, notes).
- `requests`: lo pedido a cada artista desde «Pedir al artista».
