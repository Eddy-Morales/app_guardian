# 🛡️ EcuGuardian

<p align="center">
  <img width="30%" alt="Logo EcuGuardian" src="https://github.com/user-attachments/assets/21d5c4fe-b825-4b91-96ee-b61a5cb363db" />
" />
</p>

Aplicación móvil desarrollada en **Flutter** que permite a una comunidad reportar, visualizar y gestionar incidentes de seguridad (robos, accidentes, incendios, accidentes de tránsito, entre otros) utilizando evidencia fotográfica, ubicación GPS y mapas interactivos.

La aplicación cuenta con dos tipos de usuarios:

- 👤 Cliente
- 👨‍💼 Administrador

Como backend utiliza **Supabase** y para los servicios de mapas y geolocalización integra **Google Maps Platform** y **Firebase**.

---

# 🎥 Campaña de difusión

## Video promocional

- [Video 1](https://vt.tiktok.com/ZSXy4BW9D/)
- [Video 2](https://vt.tiktok.com/ZSXDFhudr/)

## Video del funcionamiento

- [video en youtube](https://youtu.be/9D7MwTKgqEE)

## Enlace a las plataformas de descarga

- [Amazon AppStore](https://www.amazon.com/gp/product/B0H8QLM9TR)
- [Firebase Distribution](https://appdistribution.firebase.dev/i/c6d920eebc5bfe02)

---

# 📄 Informe

El informe completo del proyecto se encuentra disponible en:

[Informe final](https://epnecuador-my.sharepoint.com/:w:/g/personal/kevin_chacon_epn_edu_ec/IQBvLIi2mMQ-T5jnfPDVgJ6VAaITZ3B0TlTjZ9IhEsaISGM?e=bEU1Gl)

---

# 📱 Características principales

- Registro e inicio de sesión mediante Supabase Auth.
- Recuperación de contraseña mediante correo electrónico.
- Roles de usuario (Administrador y Cliente).
- Reporte de incidentes con:
  - Fotografía.
  - Categoría.
  - Descripción.
  - Ubicación GPS.
  - Dirección obtenida mediante Geocoding.
- Asignación automática de zonas de riesgo.
- Mapa interactivo con marcadores por categoría.
- Comentarios en tiempo real utilizando Supabase Realtime.
- Dashboard administrativo.
- Gestión de usuarios.
- Gestión de zonas.
- Gestión de incidentes.
- Reportes estadísticos.
- Firebase Analytics para estadísticas de uso.
- Firebase App Distribution para distribución de versiones de prueba.

---

# 🏗 Arquitectura

El proyecto sigue una arquitectura por capas utilizando el patrón **Repository + Provider**.

```
lib/
├── main.dart
├── app.dart
├── config/
├── models/
├── repositories/
├── providers/
├── services/
├── screens/
├── widgets/
├── utils/
└── navigation/
```

---

# 🔑 Roles

Al iniciar sesión se consulta la tabla **profiles** en Supabase y la aplicación redirige automáticamente según el rol del usuario.

| Rol | Pantalla |
|------|-----------|
| admin | HomeAdminScreen |
| client | HomeClientScreen |

---

# ☁ Backend (Supabase)

El proyecto utiliza Supabase como Backend-as-a-Service.

Servicios utilizados:

- Auth
- PostgreSQL
- Storage
- Realtime
- Row Level Security (RLS)

### Tablas

**profiles**

- uid
- name
- email
- role
- blocked
- created_at

**incidents**

- id
- user_id
- category
- description
- lat
- lng
- address
- photo_url
- zone_id
- created_at

**zones**

- id
- name
- risk_level
- incident_count
- center_lat
- center_lng
- radius_km

**comments**

- id
- incident_id
- user_id
- message
- created_at

Storage:

```
incidents
```

---

# 🔥 Firebase

La aplicación integra Firebase para:

- Firebase Analytics
- Firebase App Distribution

---

# 📲 Firebase App Distribution

La distribución para testers se realiza mediante Firebase App Distribution.

1. Ingresar a Firebase Console.
2. Abrir App Distribution.
3. Crear una nueva versión.
4. Subir el APK.
5. Agregar los correos electrónicos de los testers.
6. Distribuir la aplicación.

Los testers recibirán un correo electrónico con el enlace de instalación.

Firebase permite consultar:

- Invitaciones enviadas.
- Invitaciones aceptadas.
- Descargas realizadas.
- Versiones distribuidas.

---

# ▶ Instalación

Clonar el repositorio.

Instalar dependencias.

```bash
flutter pub get
```

Ejecutar:

```bash
flutter run
```

---

## Variables de entorno

Crear un archivo `.env` con:

```
SUPABASE_URL=
SUPABASE_ANON_KEY=
GOOGLE_MAPS_API_KEY=
```

---

# ⚙ Requisitos

- Flutter SDK
- Dart 3.12.1
- Android Studio
- Proyecto en Supabase
- Proyecto en Firebase
- Google Maps Platform
- Geocoding API habilitada

---

# 📦 Compilación

APK

```bash
flutter build apk --release
```

AAB

```bash
flutter build appbundle --release
```

Launcher Icons

```bash
flutter pub run flutter_launcher_icons
```

Splash Screen

```bash
flutter pub run flutter_native_splash:create
```

---

# 📚 Dependencias principales

| Paquete | Descripción |
|-----------|----------------|
| supabase_flutter | Backend |
| provider | Gestión de estado |
| google_maps_flutter | Mapa |
| geolocator | GPS |
| image_picker | Cámara |
| firebase_core | Inicialización Firebase |
| firebase_analytics | Analíticas |
| connectivity_plus | Estado de conexión |
| http | Geocoding |

---

# 🌿 Ramas

- master
- main
- feature/progreso-proyecto

---

# 📸 Capturas del funcionamiento

## Panel administrador

### 🏠 Home

<p align="center">
  <img src="https://github.com/user-attachments/assets/139dc128-ae3d-412e-bfd7-aeafd336318a" width="30%"/>
</p>

### 👤 Perfil

<p align="center">
  <img src="https://github.com/user-attachments/assets/4d6d4c74-aed2-4800-b6a5-ca39255df38e" width="30%"/>
</p>

### 📍 Zonas

<p align="center">
  <img src="https://github.com/user-attachments/assets/af6184f6-ff91-44af-92b6-71bd50a311fa" width="250"/>
  <img src="https://github.com/user-attachments/assets/4e637a40-84df-463c-93a5-6f4842fcbc10" width="250"/>
</p>

### 👥 Usuarios

<p align="center">
  <img src="https://github.com/user-attachments/assets/4d48a25c-cf1a-4979-9fda-addda93b6293" width="250"/>
</p>

### 📊 Reportes

<p align="center">
  <img src="https://github.com/user-attachments/assets/a3843665-b487-465f-aeb4-233563a9afec" width="250"/>
</p>

### 🚨 Incidentes

<p align="center">
  <img src="https://github.com/user-attachments/assets/f463c5b5-aa2e-4e01-996b-5fd548006d72" width="250"/>
  <img src="https://github.com/user-attachments/assets/2074dee8-e142-4797-a257-3241a9f5b1c6" width="250"/>
</p>

### 🗺️ Mapa

<p align="center">
  <img src="https://github.com/user-attachments/assets/b81c2f6e-8506-4bf9-98be-b2af36dec927" width="250"/>
</p>

---

## Panel usuario

### 🏠 Home

<p align="center">
  <img src="https://github.com/user-attachments/assets/6f9df669-7f39-45c8-880b-10d033432003" width="250"/>
</p>

### 🔑 Recuperar contraseña

<p align="center">
  <img src="https://github.com/user-attachments/assets/24a00cda-78ff-4e4b-ae63-f384281ebfee" width="250"/>
</p>

### 📝 Registro

<p align="center">
  <img src="https://github.com/user-attachments/assets/d679e0ec-b400-4fbb-bb2a-732ed18434fe" width="250"/>
</p>

---

# 👥 Equipo

Proyecto desarrollado como parte de la asignatura de Desarrollo de Aplicaciones Móviles de la Escuela Politécnica Nacional.
