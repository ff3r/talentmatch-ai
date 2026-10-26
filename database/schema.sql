-- ==============================================================================
-- SISTEMA: TALENTMATCH AI (talentmatch-ai-V2)
-- DESCRIPCION: Script DDL de creación de Base de Datos y Tablas Normalizadas (3FN)
-- MOTOR: MySQL 8.0+ / MariaDB 10.4+ (InnoDB, UTF-8 Multilingüe)
-- CONVENCION: snake_case en identificadores, singular estricto según mer_normalizao.xml
-- ==============================================================================

-- 1. CREACION DE LA BASE DE DATOS
DROP DATABASE IF EXISTS talentmatch_db;
CREATE DATABASE talentmatch_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE talentmatch_db;

-- ==============================================================================
-- TABLA 1: rol
-- Corresponde a la entidad ROL de mer_normalizao.xml
-- ==============================================================================
CREATE TABLE rol (
    id_rol INT AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255) NULL,
    CONSTRAINT pk_rol PRIMARY KEY (id_rol),
    CONSTRAINT uk_rol_nombre UNIQUE (nombre)
);

-- ==============================================================================
-- TABLA 2: usuario
-- Corresponde a la entidad USUARIO de mer_normalizao.xml
-- Relación con rol: asigna (1:N)
-- ==============================================================================
CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT,
    id_rol INT NOT NULL,
    email VARCHAR(150) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    nombre_completo VARCHAR(150) NULL,
    telefono VARCHAR(30) NULL,
    estado ENUM('activo', 'inactivo', 'pendiente') NOT NULL DEFAULT 'activo',
    token_activacion VARCHAR(255) NULL,
    token_expira_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT uk_usuario_email UNIQUE (email),
    CONSTRAINT fk_usuario_rol FOREIGN KEY (id_rol)
        REFERENCES rol(id_rol)
        ON DELETE RESTRICT
);

-- ==============================================================================
-- TABLA 3: empresa
-- Corresponde a la entidad EMPRESA de mer_normalizao.xml
-- Relación con usuario: administra (1:1)
-- ==============================================================================
CREATE TABLE empresa (
    id_empresa INT AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    ruc VARCHAR(20) NOT NULL,
    razon_social VARCHAR(150) NOT NULL,
    sector_industrial VARCHAR(100) NULL,
    ubicacion_sede VARCHAR(150) NOT NULL,
    sitio_web VARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_empresa PRIMARY KEY (id_empresa),
    CONSTRAINT uk_empresa_usuario UNIQUE (id_usuario),
    CONSTRAINT uk_empresa_ruc UNIQUE (ruc),
    CONSTRAINT fk_empresa_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE
);

-- ==============================================================================
-- TABLA 4: reclutador
-- Corresponde a la entidad RECLUTADOR de mer_normalizao.xml
-- Relación con usuario: autentica (1:1)
-- Relación con empresa: emplea (1:N)
-- ==============================================================================
CREATE TABLE reclutador (
    id_reclutador INT AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    id_empresa INT NOT NULL,
    numero_documento VARCHAR(20) NULL,
    cargo_empresa VARCHAR(100) NOT NULL,
    area_departamento VARCHAR(100) NULL DEFAULT 'Recursos Humanos',
    CONSTRAINT pk_reclutador PRIMARY KEY (id_reclutador),
    CONSTRAINT uk_reclutador_usuario UNIQUE (id_usuario),
    CONSTRAINT uk_reclutador_documento UNIQUE (numero_documento),
    CONSTRAINT fk_reclutador_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,
    CONSTRAINT fk_reclutador_empresa FOREIGN KEY (id_empresa)
        REFERENCES empresa(id_empresa)
        ON DELETE CASCADE
);

-- ==============================================================================
-- TABLA 5: postulante
-- Corresponde a la entidad POSTULANTE de mer_normalizao.xml
-- Relación con usuario: autentica (1:1)
-- ==============================================================================
CREATE TABLE postulante (
    id_postulante INT AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    numero_documento VARCHAR(20) NOT NULL,
    tipo_documento VARCHAR(20) NOT NULL DEFAULT 'DNI',
    titular_profesional VARCHAR(150) NOT NULL,
    resumen_biografico TEXT NULL,
    anos_experiencia INT NOT NULL DEFAULT 0,
    url_curriculum_pdf VARCHAR(255) NULL,
    porcentaje_completitud DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_postulante PRIMARY KEY (id_postulante),
    CONSTRAINT uk_postulante_usuario UNIQUE (id_usuario),
    CONSTRAINT uk_postulante_documento UNIQUE (numero_documento),
    CONSTRAINT fk_postulante_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE
);

-- ==============================================================================
-- TABLA 6: formacion
-- Corresponde a la entidad débil FORMACION de mer_normalizao.xml
-- Relación con postulante: acredita (1:N, identificadora)
-- ==============================================================================
CREATE TABLE formacion (
    id_formacion INT AUTO_INCREMENT,
    id_postulante INT NOT NULL,
    institucion VARCHAR(150) NOT NULL,
    grado_obtenido VARCHAR(150) NOT NULL,
    anio_egreso INT NULL,
    CONSTRAINT pk_formacion PRIMARY KEY (id_formacion),
    CONSTRAINT fk_formacion_postulante FOREIGN KEY (id_postulante)
        REFERENCES postulante(id_postulante)
        ON DELETE CASCADE
);

-- ==============================================================================
-- TABLA 7: experiencia
-- Corresponde a la entidad débil EXPERIENCIA de mer_normalizao.xml
-- Relación con postulante: registra (1:N, identificadora)
-- ==============================================================================
CREATE TABLE experiencia (
    id_experiencia INT AUTO_INCREMENT,
    id_postulante INT NOT NULL,
    empresa VARCHAR(150) NOT NULL,
    cargo VARCHAR(150) NOT NULL,
    periodo VARCHAR(100) NOT NULL,
    funciones_desempenadas TEXT NULL,
    CONSTRAINT pk_experiencia PRIMARY KEY (id_experiencia),
    CONSTRAINT fk_experiencia_postulante FOREIGN KEY (id_postulante)
        REFERENCES postulante(id_postulante)
        ON DELETE CASCADE
);

-- ==============================================================================
-- TABLA 8: oferta_laboral
-- Corresponde a la entidad OFERTA_LABORAL de mer_normalizao.xml
-- Relación con empresa: publica (1:N)
-- Relación con reclutador: gestiona (1:N, opcional)
-- ==============================================================================
CREATE TABLE oferta_laboral (
    id_oferta_laboral INT AUTO_INCREMENT,
    id_empresa INT NOT NULL,
    id_reclutador INT NULL,
    codigo_oferta VARCHAR(30) NOT NULL,
    titulo_puesto VARCHAR(150) NOT NULL,
    area_puesto VARCHAR(100) NULL,
    descripcion TEXT NULL,
    modalidad ENUM('Remoto', 'Presencial', 'Hibrido') NOT NULL DEFAULT 'Presencial',
    ubicacion VARCHAR(100) NULL,
    anos_experiencia_minima INT NOT NULL DEFAULT 0,
    estado ENUM('activa', 'pausada', 'cerrada') NOT NULL DEFAULT 'activa',
    fecha_publicacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_oferta_laboral PRIMARY KEY (id_oferta_laboral),
    CONSTRAINT uk_oferta_codigo UNIQUE (codigo_oferta),
    CONSTRAINT fk_oferta_empresa FOREIGN KEY (id_empresa)
        REFERENCES empresa(id_empresa)
        ON DELETE CASCADE,
    CONSTRAINT fk_oferta_reclutador FOREIGN KEY (id_reclutador)
        REFERENCES reclutador(id_reclutador)
        ON DELETE SET NULL
);

-- ==============================================================================
-- TABLA 9: requisito_oferta
-- Corresponde a la entidad débil REQUISITO_OFERTA de mer_normalizao.xml
-- Relación con oferta_laboral: exige (1:N, identificadora)
-- ==============================================================================
CREATE TABLE requisito_oferta (
    id_requisito_oferta INT AUTO_INCREMENT,
    id_oferta_laboral INT NOT NULL,
    descripcion_habilidad VARCHAR(150) NOT NULL,
    tipo ENUM('tecnico', 'blanda', 'idioma', 'certificacion') NOT NULL DEFAULT 'tecnico',
    nivel_requerido VARCHAR(50) NOT NULL DEFAULT 'Obligatorio',
    CONSTRAINT pk_requisito_oferta PRIMARY KEY (id_requisito_oferta),
    CONSTRAINT fk_requisito_oferta_laboral FOREIGN KEY (id_oferta_laboral)
        REFERENCES oferta_laboral(id_oferta_laboral)
        ON DELETE CASCADE
);

-- ==============================================================================
-- TABLA 10: postulacion
-- Corresponde a la entidad intermedia POSTULACION de mer_normalizao.xml
-- Resuelve la relación N:M entre postulante (aplica_en) y oferta_laboral (recibe)
-- ==============================================================================
CREATE TABLE postulacion (
    id_postulacion INT AUTO_INCREMENT,
    id_oferta_laboral INT NOT NULL,
    id_postulante INT NOT NULL,
    codigo_postulacion VARCHAR(30) NOT NULL,
    fecha_postulacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('Enviada', 'En Revision', 'Preseleccionado', 'Descartado') NOT NULL DEFAULT 'Enviada',
    CONSTRAINT pk_postulacion PRIMARY KEY (id_postulacion),
    CONSTRAINT uk_postulacion_codigo UNIQUE (codigo_postulacion),
    CONSTRAINT uk_postulacion_candidato_oferta UNIQUE (id_oferta_laboral, id_postulante),
    CONSTRAINT fk_postulacion_oferta FOREIGN KEY (id_oferta_laboral)
        REFERENCES oferta_laboral(id_oferta_laboral)
        ON DELETE CASCADE,
    CONSTRAINT fk_postulacion_postulante FOREIGN KEY (id_postulante)
        REFERENCES postulante(id_postulante)
        ON DELETE CASCADE
);

-- ==============================================================================
-- TABLA 11: evaluacion_ia
-- Corresponde a la entidad EVALUACION_IA de mer_normalizao.xml
-- Relación con postulacion: analizada_por (1:1)
-- ==============================================================================
CREATE TABLE evaluacion_ia (
    id_evaluacion_ia INT AUTO_INCREMENT,
    id_postulacion INT NOT NULL,
    puntaje_matching DECIMAL(5,2) NOT NULL,
    clasificacion ENUM('Alto', 'Medio', 'Bajo') NOT NULL DEFAULT 'Medio',
    justificacion_semantica TEXT NOT NULL,
    modelo_ia_utilizado VARCHAR(100) NOT NULL DEFAULT 'TalentMatch-SentenceBERT-v1',
    fecha_evaluacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_evaluacion_ia PRIMARY KEY (id_evaluacion_ia),
    CONSTRAINT uk_evaluacion_postulacion UNIQUE (id_postulacion),
    CONSTRAINT fk_evaluacion_postulacion FOREIGN KEY (id_postulacion)
        REFERENCES postulacion(id_postulacion)
        ON DELETE CASCADE
);


-- ==============================================================================
-- 3. DATOS SEMILLA (INSERCIONES DML PARA OPERATIVIDAD DEL SISTEMA)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- A. ROLES DEL SISTEMA
-- ------------------------------------------------------------------------------
INSERT INTO rol (id_rol, nombre, descripcion) VALUES
(1, 'Empresa', 'Acceso al panel corporativo, gestión de ofertas de empleo y equipo de reclutadores'),
(2, 'Reclutador', 'Gestión de procesos de selección, evaluación de postulantes y matching con IA'),
(3, 'Postulante', 'Búsqueda de empleo, registro de perfil profesional, CV y seguimiento de postulaciones'),
(4, 'Administrador', 'Control maestro del sistema, gestión de catálogos y parámetros globales');

-- ------------------------------------------------------------------------------
-- B. USUARIOS INICIALES (Credenciales con Hashing Criptográfico bcrypt estándar)
-- NOTA DE SEGURIDAD ACADÉMICA / OWASP:
-- Las empresas serias y los estándares de ciberseguridad NUNCA guardan contraseñas
-- en texto claro ni permiten que administradores o dueños vean las claves de nadie.
-- Se almacena un hash irreversible generado con algoritmo bcrypt ($2y$10$...).
--
-- Contraseñas en texto claro de prueba para la sustentación:
-- 1. empresa@talentmatch.com      => Empresa2026*
-- 2. reclutador@talentmatch.com   => Reclutador2026*
-- 3. postulante@talentmatch.com   => Postulante2026*
-- 4. admin@talentmatch.com        => Admin2026*
-- 5. maria.invitada@techcorp.com  => [Sin contraseña aún - Token de activación pendiente]
-- ------------------------------------------------------------------------------
INSERT INTO usuario (id_usuario, id_rol, email, password_hash, nombre_completo, telefono, estado, token_activacion, token_expira_at) VALUES
(1, 1, 'empresa@talentmatch.com',    '$2y$10$B4zOXpnL5HYtNMRQCHsEzerx.O2Z8y.zmv2EbokYQrvYM6uSsn5LW', 'TechCorp Internacional S.A.', '+51 987654321', 'activo', NULL, NULL),
(2, 2, 'reclutador@talentmatch.com', '$2y$10$t2sBO07OuRIAPGUoh5HkGO/AbUjwAC1HuEEcgW2N7h1I54SYIdLZW', 'Ana Patricia Martinez',       '+51 912345678', 'activo', NULL, NULL),
(3, 3, 'postulante@talentmatch.com', '$2y$10$SgH9E.GupFmePm/lzRz4XO91fHb2YqTeMCRXKXoE3ztjPVRutWNh.', 'Carlos Eduardo Lopez',         '+51 998877665', 'activo', NULL, NULL),
(4, 4, 'admin@talentmatch.com',      '$2y$10$7gdt5iAO3VISqNbUeD5qbu/u0wuJOXlVcvMp0bkeCAkDPael0ljru', 'Administrador del Sistema',    '+51 900112233', 'activo', NULL, NULL),
(5, 2, 'maria.invitada@techcorp.com','$2y$10$t2sBO07OuRIAPGUoh5HkGO/AbUjwAC1HuEEcgW2N7h1I54SYIdLZW', 'María Fernanda Gómez',        NULL,            'pendiente', 'tok_act_98f7a1c4e2b0', '2026-11-01 23:59:59');

-- ------------------------------------------------------------------------------
-- C. REGISTRO DE EMPRESA (1:1 con usuario id_usuario = 1)
-- ------------------------------------------------------------------------------
INSERT INTO empresa (id_empresa, id_usuario, ruc, razon_social, sector_industrial, ubicacion_sede, sitio_web) VALUES
(1, 1, '20601234567', 'TechCorp Internacional S.A.', 'Tecnología y Desarrollo de Software', 'San Isidro, Lima, Perú', 'https://techcorp.example.com');

-- ------------------------------------------------------------------------------
-- D. REGISTRO DE RECLUTADORES (1:1 con usuario, 1:N con empresa)
-- ------------------------------------------------------------------------------
INSERT INTO reclutador (id_reclutador, id_usuario, id_empresa, numero_documento, cargo_empresa, area_departamento) VALUES
(1, 2, 1, '72345678', 'Reclutador Senior', 'Recursos Humanos y Atracción de Talento'),
(2, 5, 1, NULL,       'Reclutador',        'Recursos Humanos y Atracción de Talento');

-- ------------------------------------------------------------------------------
-- E. REGISTRO DE POSTULANTE (1:1 con usuario id_usuario = 3)
-- ------------------------------------------------------------------------------
INSERT INTO postulante (id_postulante, id_usuario, numero_documento, tipo_documento, titular_profesional, resumen_biografico, anos_experiencia, url_curriculum_pdf, porcentaje_completitud) VALUES
(1, 3, '45678912', 'DNI', 'Desarrollador Full Stack & Arquitecto de Software', 'Ingeniero de Sistemas con más de 5 años diseñando aplicaciones web de alto rendimiento y soluciones escalables con IA.', 5, 'https://talentmatch.example.com/cvs/carlos-eduardo-lopez.pdf', 95.00);

-- ------------------------------------------------------------------------------
-- F. FORMACIÓN Y EXPERIENCIA DEL POSTULANTE (Entidades débiles)
-- ------------------------------------------------------------------------------
INSERT INTO formacion (id_formacion, id_postulante, institucion, grado_obtenido, anio_egreso) VALUES
(1, 1, 'Universidad Nacional Mayor de San Marcos', 'Bachiller en Ingeniería de Sistemas', 2021);

INSERT INTO experiencia (id_experiencia, id_postulante, empresa, cargo, periodo, funciones_desempenadas) VALUES
(1, 1, 'Innovatech Latam', 'Senior Software Engineer', '2022 - Actualidad', 'Liderazgo técnico en desarrollo de microservicios, optimización de queries SQL y arquitectura frontend.');

-- ------------------------------------------------------------------------------
-- G. OFERTA LABORAL DE PRUEBA
-- ------------------------------------------------------------------------------
INSERT INTO oferta_laboral (id_oferta_laboral, id_empresa, id_reclutador, codigo_oferta, titulo_puesto, area_puesto, descripcion, modalidad, ubicacion, anos_experiencia_minima, estado) VALUES
(1, 1, 1, 'OFE-2026-001', 'Desarrollador Full Stack Senior', 'Tecnología', 'Buscamos un Ingeniero de Software para liderar el desarrollo de nuestros servicios cloud.', 'Hibrido', 'Lima, Perú', 4, 'activa');

INSERT INTO requisito_oferta (id_requisito_oferta, id_oferta_laboral, descripcion_habilidad, tipo, nivel_requerido) VALUES
(1, 1, 'JavaScript / TypeScript', 'tecnico', 'Obligatorio'),
(2, 1, 'Bases de Datos Relacionales (SQL / 3FN)', 'tecnico', 'Obligatorio'),
(3, 1, 'Inglés Intermedio / Técnico', 'idioma', 'Deseable');
