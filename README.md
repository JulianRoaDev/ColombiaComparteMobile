# Latinoamérica Comparte

## 🌎 Resumen rápido

Latinoamérica Comparte es una plataforma para que administradores y editores gestionen contenido (noticias, testimonios y solicitudes) desde una API en Node.js/TypeScript y una app móvil en Flutter.

Este README resume cómo poner en marcha el backend y la app móvil, cómo usar los endpoints principales y dónde mirar si algo falla.

---

## 🚀 Qué hay en este repositorio

- `Backend/`: API REST con Express + TypeScript y MongoDB (Mongoose). Revisa los scripts de npm en [Backend/package.json](Backend/package.json#L1-L200).
- `Mobile/`: app de administración construida con Flutter.

---

## 🧭 Rápida descripción técnica

- Backend: Node.js, Express, TypeScript, Mongoose. Autenticación con JWT y hash de contraseñas con `bcryptjs`.
- Mobile: Flutter (Dart), `dio` para HTTP, `flutter_secure_storage` para guardar el JWT.

---

**Estructura importante**

- Backend principal: [Backend/src/server.ts](Backend/src/server.ts#L1-L200)
- Script de seed: `npm run seed` (ejecutar desde `Backend/`)

---

## ⚙️ Backend — Inicio rápido

1. Instala dependencias:

```bash
cd Backend
npm install
```

2. Crea un archivo `.env` en la carpeta `Backend/` con al menos estas variables:

```env
PORT=4000
MONGO_URI=mongodb://localhost:27017/latam_comparte
JWT_SECRET=tu_secreto_aqui
JWT_EXPIRES_IN=24h
```

3. En desarrollo (recarga automática usando `tsx`):

```bash
npm run dev
```

4. Para producción:

```bash
npm run build
npm start
```

5. Para cargar datos de ejemplo (seed):

```bash
npm run seed
```

Notas:
- Los scripts disponibles están en [Backend/package.json](Backend/package.json#L1-L200).
- Si la conexión a Mongo falla, revisa `MONGO_URI` y que MongoDB esté corriendo en la máquina o en un servicio accesible.

---

## 🔐 Autenticación

- El backend utiliza JWT. Al iniciar sesión obtendrás un token que debes enviar en el header `Authorization: Bearer <token>` para rutas protegidas.
- Cuando actualices el perfil, el backend emite un nuevo token: guarda el token actualizado en el cliente.

---

## 🧾 Endpoints principales (resumen)

Estos son los endpoints más usados por la app móvil. Rutas base: `/auth`, `/usuarios`, `/noticias`, `/testimonios`, `/paises`, `/solicitudes`, `/dashboard`.

- `POST /auth/login` — Inicia sesión. Body: `{ email, password }`. Respuesta: `{ user, token }`.
- `POST /auth/register` — Crear usuario. Body: `{ nombre, email, password, rol? }`.
- `PATCH /auth/perfil` — Actualizar perfil (protegida). Enviar `Authorization` y body con campos a actualizar.

Ejemplo rápido con `curl` (login):

```bash
curl -X POST http://localhost:4000/auth/login \
	-H "Content-Type: application/json" \
	-d '{"email":"admin@example.com","password":"tu_pass"}'
```

Para más endpoints y detalles, abre los controladores en `Backend/src/controllers/`.

---

## 📱 Mobile — Inicio rápido

1. Instala dependencias y ejecuta desde `Mobile/`:

```bash
cd Mobile
flutter pub get
flutter run
```

2. Configuración en la app:
- La app espera consumir la API del backend. Asegúrate de apuntar `baseUrl` al host donde corre el backend (revisa `lib/core` en la app).
- El token JWT se guarda en `flutter_secure_storage`.

---

## 🧪 Seed y datos de prueba

- Para poblar la DB con datos de ejemplo: desde `Backend/` ejecuta `npm run seed`.
- El seed crea usuarios, países y ejemplos de noticias/testimonios para probar la app.

---

## 🛠️ Sugerencias de troubleshooting

- Error de conexión a MongoDB: verifica `MONGO_URI` y que el servicio esté en ejecución.
- Error 401 en rutas protegidas: revisa que el token JWT se envíe como `Authorization: Bearer <token>`.
- Problemas con la imagen de perfil: la app usa URLs públicas; si no carga, muestra la inicial del nombre.

---

## 🤝 Cómo contribuir

- Si quieres contribuir, haz un fork, crea una rama con tu feature/bugfix y abre un PR describiendo los cambios.
- Añade tests cuando sea posible y documenta cualquier cambio en las APIs.

---

## 📬 Contacto

Si necesitas ayuda para poner todo en marcha o quieres que ajuste la API para el frontend, dime y lo revisamos juntos.

---

*Este README fue escrito para ser directo y práctico — si quieres que lo traduzca a inglés, lo reduzca o lo amplíe con ejemplos completos de peticiones, dímelo y lo hago.*

---
