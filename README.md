# TalentMatch AI

> **Plataforma inteligente de reclutamiento y selección de talento impulsada por Inteligencia Artificial.**  
> Arquitectura web distribuida con frontend responsivo (Vanilla HTML5/CSS3/ES6+), API backend ligera en PHP con PDO y persistencia relacional en MySQL normalizada en Tercera Forma Normal (3FN).

---

## 1. Arquitectura Técnica del Proyecto

El sistema está estructurado bajo una arquitectura de tres capas limpiamente desacopladas:

1. **Capa de Presentación (Frontend):**
   * HTML5 semántico y CSS modular con diseño responsive.
   * Vanilla JavaScript (ES6+) con cliente HTTP asíncrono (`js/services/api-client.js`).
   * Envío real de notificaciones e invitaciones por correo mediante EmailJS.
   * **Modo Híbrido Resiliente:** Si el backend MySQL está activo, opera con persistencia real; si se ejecuta en entornos estáticos (GitHub Pages), activa automáticamente un fallback local sin interrumpir la navegación.

2. **Capa de Servicios y Negocio (API Backend):**
   * PHP 8.0+ con arquitectura RESTful en la carpeta `/api/`.
   * Conector centralizado PDO (`Database.php`) bajo el patrón de diseño creacional **Singleton**.
   * Sentencias preparadas nativas (`PDO::ATTR_EMULATE_PREPARES => false`) con protección contra Inyección SQL (OWASP).
   * Hashing criptográfico irreversible de contraseñas mediante algoritmo **bcrypt** con sal aleatoria (`password_hash` / `password_verify`).
   * Transacciones atómicas (`beginTransaction` / `commit`) para la publicación de convocatorias y sus requisitos.

3. **Capa de Persistencia (Base de Datos):**
   * Motor: **MySQL 8.0+** / **MariaDB 10.4+** (InnoDB, UTF-8 Multilingüe `utf8mb4`).
   * Modelo relacional con **11 entidades normalizadas en 3FN**.
   * Claves primarias numéricas subrogadas, claves foráneas con restricciones referenciales y claves alternas únicas.

---

## 2. Requisitos del Sistema

* **PHP:** Versión 8.0 o superior (con extensión `pdo_mysql` habilitada).
* **Base de Datos:** MySQL 8.0+ o MariaDB 10.4+ (ej. XAMPP, WampServer, Docker o servicio local).
* **Gestor de BD (Opcional):** DataGrip, MySQL Workbench, DBeaver o phpMyAdmin.
* **Navegador Web:** Google Chrome, Microsoft Edge, Mozilla Firefox o Safari actualizado.

---

## 3. Instrucciones de Despliegue y Pruebas Locales

Siga los siguientes pasos para levantar y evaluar el proyecto con base de datos real:

### Paso 1: Clonar el Repositorio
```bash
git clone https://github.com/ff3r/talentmatch-ai.git
cd talentmatch-ai
```

### Paso 2: Crear e Importar la Base de Datos
1. Inicie el servicio de MySQL en su entorno local (puerto 3306).
2. Abra su cliente SQL de preferencia (DataGrip, Workbench o phpMyAdmin).
3. Abra y ejecute el script completo ubicado en:
   ```text
   database/schema.sql
   ```
   > **Nota:** Este script crea la base de datos `talentmatch_db`, estructura las 11 tablas en 3FN y carga automáticamente los **datos semilla iniciales (roles, usuarios, empresa, reclutadores, postulante y ofertas)**.

### Paso 3: Configurar Conexión (Opcional si usa valores estándar)
La conexión por defecto en `api/config/database.php` apunta a:
* **Host:** `127.0.0.1:3306`
* **Base de datos:** `talentmatch_db`
* **Usuario:** `root`
* **Contraseña:** `""` (vacía)

*(Si su instalación de MySQL utiliza una contraseña o puerto diferente, puede modificarlo directamente en `api/config/database.php` o definir las variables de entorno `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASS`).*

### Paso 4: Iniciar el Servidor de Desarrollo
Abra una terminal en la raíz del proyecto y ejecute el servidor web integrado de PHP:
```bash
php -S localhost:8000
```

### Paso 5: Abrir la Aplicación
Abra su navegador web e ingrese a:
* **Página Principal (Landing):** [http://localhost:8000/index.html](http://localhost:8000/index.html)
* **Diagnóstico de Conexión:** [http://localhost:8000/api/db.php](http://localhost:8000/api/db.php) (devuelve el estado de la BD en formato JSON).
* **Inicio de Sesión:** [http://localhost:8000/auth/login.html](http://localhost:8000/auth/login.html)

---

## 4. Credenciales de Prueba (Cuentas Semilla)

Para evaluar los diferentes perfiles del sistema, el script `database/schema.sql` incluye las siguientes cuentas preconfiguradas con hash `bcrypt`:

| Perfil / Rol | Correo Electrónico | Contraseña | Panel Destino | Estado |
| :--- | :--- | :--- | :--- | :--- |
| **Empresa** | `empresa@talentmatch.com` | `Empresa2026*` | `empresa/dashboard.html` | Activo |
| **Reclutador** | `reclutador@talentmatch.com` | `Reclutador2026*` | `reclutador/dashboard.html` | Activo |
| **Postulante** | `postulante@talentmatch.com` | `Postulante2026*` | `postulante/dashboard.html` | Activo |
| **Administrador** | `admin@talentmatch.com` | `Admin2026*` | `admin/dashboard.html` | Activo |
| **Reclutador Invitado** | `maria.invitada@techcorp.com` | *(Por activar vía token)* | `auth/activar-cuenta.html` | Pendiente |

---

## 5. Endpoints de la API Backend (`/api/`)

La API RESTful responde en formato JSON estándar (`success`, `message`, `data`, `errors`):

| Método | Endpoint | Descripción |
| :--- | :--- | :--- |
| `GET` | `/api/db.php` | Diagnóstico de salud y verificación de conexión a MySQL. |
| `POST` | `/api/auth/login.php` | Autenticación real contra `usuario` con verificación `bcrypt`. |
| `POST` | `/api/auth/activar-cuenta.php` | Registro de DNI, hash de contraseña y activación de cuenta. |
| `GET` | `/api/empresa/reclutadores.php` | Listado de reclutadores de la empresa con ofertas asignadas. |
| `POST` | `/api/empresa/reclutadores.php` | Registro de nuevo reclutador en estado pendiente y token temporal. |
| `PATCH` | `/api/empresa/reclutadores.php` | Alternar estado del reclutador (activo / inactivo). |
| `GET` | `/api/empresa/ofertas.php` | Listado de convocatorias laborales y conteo de postulaciones. |
| `POST` | `/api/empresa/ofertas.php` | Publicación atómica de oferta y requisitos en transacción PDO. |
| `GET` | `/api/reclutador/candidatos.php` | Consulta de postulantes con formación académica y experiencia. |

---

## 6. Estructura del Repositorio

```text
talentmatch-ai/
├── index.html                      # Landing page principal del producto
├── README.md                       # Documentación técnica y guía de despliegue
├── database/
│   └── schema.sql                  # Script DDL (3FN) e inserts semilla para MySQL
├── api/                            # Backend RESTful en PHP 8 / PDO
│   ├── config/
│   │   └── database.php            # Conector Singleton PDO con sentencias preparadas
│   ├── helpers/
│   │   └── response.php            # Respuestas JSON estándar y cabeceras CORS
│   ├── db.php                      # Healthcheck y diagnóstico de base de datos
│   ├── auth/
│   │   ├── login.php               # Endpoint de inicio de sesión
│   │   └── activar-cuenta.php      # Endpoint de activación de reclutadores
│   ├── empresa/
│   │   ├── reclutadores.php        # CRUD y ciclo de vida de reclutadores
│   │   └── ofertas.php             # Publicación y listado de convocatorias
│   └── reclutador/
│       └── candidatos.php          # Consulta de candidatos desde la BD
├── auth/                           # Pantallas de autenticación y activación
│   ├── login.html
│   ├── activar-cuenta.html
│   ├── registro-empresa.html
│   └── registro-postulante.html
├── empresa/                        # Módulo corporativo
│   ├── dashboard.html
│   ├── ofertas.html
│   ├── oferta-formulario.html
│   ├── oferta-detalle.html
│   ├── perfil.html
│   ├── configuracion.html
│   ├── reclutadores.html
│   └── reclutador-detalle.html
├── reclutador/                     # Módulo del equipo de atracción de talento
│   ├── dashboard.html
│   ├── ofertas.html
│   ├── candidatos.html
│   ├── matching.html
│   └── candidato-detalle.html
├── postulante/                     # Módulo del candidato
│   ├── dashboard.html
│   ├── perfil.html
│   ├── ofertas-disponibles.html
│   ├── oferta-detalle.html
│   └── aplicaciones.html
├── admin/                          # Módulo de administración global
│   ├── dashboard.html
│   ├── usuarios.html
│   ├── catalogos.html
│   └── parametros.html
├── css/                            # Arquitectura de estilos CSS3 modular
│   ├── variables.css
│   ├── reset.css
│   ├── layout.css
│   ├── components.css
│   ├── animations.css
│   ├── responsive.css
│   └── pages/
└── js/                             # Lógica cliente y adaptadores
    ├── auth.js
    ├── app.js
    └── services/
        └── api-client.js           # Cliente HTTP asíncrono para la API PHP
```

---

## 7. Despliegue en Línea y Modo Fallback

* **Demostración en Línea (GitHub Pages):**  
  [https://ff3r.github.io/talentmatch-ai/](https://ff3r.github.io/talentmatch-ai/)
* En entornos sin servidor backend activo, el cliente `api-client.js` conmuta de forma transparente al almacén de credenciales y datos simulados en memoria, asegurando que todos los flujos de navegación sean plenamente evaluables sin interrupciones.
