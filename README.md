# De usuario anónimo a cuenta real · Flutter + Supabase

**Episodio 2 de 8** de la serie *Flutter + Supabase con Claude Code* de [Brainglab](https://www.youtube.com/@brainglab). Es la app que se explica en el video, tal como queda al final del episodio.

## Qué hay en este episodio

- Guardar la cuenta en 3 pasos: `updateUser` (correo), `verifyOTP` (código) y `updateUser` (contraseña).
- El `id` del usuario no cambia: las políticas de RLS le siguen dando sus tareas.
- Plantilla de correo con el código (`{{ .Token }}`).
- Entrar en otro dispositivo con `signInWithPassword`.

## Versiones

Flutter 3.47.5 (con [FVM](https://fvm.app), fijado en `.fvmrc`) · supabase_flutter 2.17 · Supabase CLI 2.118

## Ejecutar con Supabase local

```bash
fvm install                 # la versión de Flutter de .fvmrc (3.47.5)
fvm flutter pub get
supabase start              # Supabase completo en local (necesita Docker)
supabase status             # copia API_URL y PUBLISHABLE_KEY a .env.local (ver .env.example)
fvm flutter run -d chrome --dart-define-from-file=.env.local
# Los correos con el código llegan a Mailpit: http://127.0.0.1:54324
```

## Seguridad

- Los `.env` están en `.gitignore`. La app solo usa la **publishable key**, que puede ir en el cliente; la **secret key** nunca entra en la app.
- Cada tabla tiene RLS activo y una política por operación (`supabase/migrations/`).

## La serie

| # | Episodio |
|---|---|
| 1 | [App de tareas con Flutter, Supabase y Claude Code](https://github.com/brainglab/flutter-supabase-e01-app-tareas) |
| 2 | [De usuario anónimo a cuenta real](https://github.com/brainglab/flutter-supabase-e02-de-anonimo-a-cuenta) **(este episodio)** |
| 3 | [Guardar la cuenta con Google (web)](https://github.com/brainglab/flutter-supabase-e03-cuenta-con-google) |
| 4 | [Google en Android e iOS](https://github.com/brainglab/flutter-supabase-e04-google-nativo) |
| 5 | [Editar y borrar tareas](https://github.com/brainglab/flutter-supabase-e05-editar-y-borrar) |
| 6 | [Recuperar la contraseña con un código](https://github.com/brainglab/flutter-supabase-e06-recuperar-contrasena) |
| 7 | [Borrar la cuenta y sus datos (Edge Function)](https://github.com/brainglab/flutter-supabase-e07-borrar-cuenta) |
| 8 | [De local a la nube (final de la serie)](https://github.com/brainglab/flutter-supabase-e08-de-local-a-la-nube) |

Hecho por [Brainglab](https://www.brainglab.com) · videos en [YouTube](https://www.youtube.com/@brainglab).
