# Latinoamérica Comparte

## 🌎 Proyecto Full Stack

Este repositorio contiene la aplicación **Latinoamérica Comparte**, con:

- `Backend/`: API REST en **Node.js + Express + TypeScript** con persistencia en **MongoDB**.
- `Mobile/`: aplicación móvil de administración construida en **Flutter**.

---

## 🚀 Descripción

Latinoamérica Comparte es una plataforma de administración de contenido donde los usuarios pueden iniciar sesión, actualizar su perfil y gestionar recursos como noticias, testimonios y solicitudes. El backend brinda autenticación JWT y endpoints para operaciones CRUD, mientras que la app móvil ofrece un panel de control para administradores y editores.

---

## 🧩 Tecnologías usadas

### Backend

- Node.js
- Express
- TypeScript
- MongoDB / Mongoose
- JWT para autenticación
- bcryptjs para hash de contraseñas
- dotenv para configuración de entorno
- CORS

### Mobile

- Flutter
- Dart
- Provider para estado
- Dio para llamadas HTTP
- flutter_secure_storage para token seguro
- go_router para navegación

---

## 📁 Estructura del proyecto

### Backend/

- `src/server.ts`: archivo principal que inicia el servidor.
- `src/config/db.ts`: configuración de conexión MongoDB.
- `src/controllers/`: lógica de controladores para auth, usuarios, noticias, testimonios, paises y solicitudes.
- `src/routes/`: rutas de Express.
- `src/models/`: esquemas de MongoDB.
- `src/middleware/auth.ts`: verificación de JWT.
- `src/seed/seed.ts`: script para cargar datos iniciales.
- `src/types/express.t.ts`: tipos adicionales para Express.

### Mobile/

- `lib/main.dart`: punto de entrada de Flutter.
- `lib/core/`: configuración de red y constantes.
- `lib/features/auth/`: modelo, servicios, provider y pantallas de autenticación.
- `lib/features/perfil/`: pantalla de perfil personal.
- `lib/shared/`: widgets compartidos como drawer y confirm dialog.
- `lib/router/`: configuración de rutas con `go_router`.

---

## ⚙️ Configuración y ejecución

### Backend

1. Instalar dependencias:

```bash
cd Backend
npm install
```

2. Configurar variables de entorno en `.env` (debe existir en `Backend/`):

```env
PORT=4000
MONGO_URI=mongodb://localhost:27017/latam_comparte
JWT_SECRET=tu_secreto_aqui
JWT_EXPIRES_IN=24h
```

3. Ejecutar en modo desarrollo:

```bash
npm run dev
```

4. Compilar y ejecutar en producción:

```bash
npm run build
npm start
```

5. Cargar datos de ejemplo:

```bash
npm run seed
```

### Mobile

1. Instalar dependencias de Flutter:

```bash
cd Mobile
flutter pub get
```

2. Ejecutar la app:

```bash
flutter run
```

---

## ✅ Endpoints principales del backend

- `POST /auth/login`: login de usuario.
- `POST /auth/register`: registro de usuario.
- `PATCH /auth/perfil`: actualizar perfil del usuario autenticado.
- `POST /auth/perfil`: ruta compatible para actualización de perfil.

---

## 🧠 Notas importantes

- El backend genera un nuevo token al actualizar el perfil, de modo que el frontend debe guardar nuevamente el JWT.
- La app móvil maneja la imagen de perfil como URL pública. Si la URL es inválida, se muestra la inicial del nombre.

---

## ✨ Mejora reciente

Se reforzó la actualización de perfil para que:

- acepte la imagen de perfil como URL válida `http` / `https`
- soporte fallback visual cuando la imagen no carga
- muestre la inicial del nombre si no hay imagen disponible

---
