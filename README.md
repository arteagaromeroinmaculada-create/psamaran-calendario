# Calendario de marketing PSamarán

Calendario compartido de funciones, publicaciones de artistas, campañas y material de PSamarán y Sala Tabor.

- **Web estática** (`index.html`), sin compilación. Se publica tal cual en Vercel.
- **Supabase** para el login con email y contraseña y para guardar los datos.
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

- **Dar acceso**: pestaña **Equipo**, escribir el email y «Dar acceso». A esa persona le llega un correo para elegir su contraseña («Reenviar correo» si no le llega).
- **Quitar acceso**: «Quitar acceso» en la misma pestaña.
- **Contraseña olvidada**: «He olvidado mi contraseña» en la pantalla de entrada. Dentro de la app, «Cambiar contraseña».

### Ajustes necesarios en Supabase
- **Authentication > Sign In / Providers > Email**: desactivar **Confirm email** (el correo que vale es el de elegir contraseña).
- **Authentication > Emails > SMTP Settings**: correo propio (por ejemplo Gmail con contraseña de aplicación: `smtp.gmail.com`, puerto 587). Sin esto Supabase solo envía unos 2 correos por hora.
- **Authentication > Rate Limits**: subir los correos por hora (por ejemplo a 30).

## Estructura de datos

Todo vive en la tabla `docs` (`collection`, `id`, `data`):
- `shows`: espectáculos (name, artist, date, time, venue, audience, notes).
- `items`: tareas del calendario (type publicacion/campana/material/tarea, title, show, date, time, status pendiente/curso/hecho/bloqueado, owner, notes).
- `requests`: lo pedido a cada artista desde «Pedir al artista».
