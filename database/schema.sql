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
) ENGINE=InnoDB;

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
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

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
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

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
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_reclutador_empresa FOREIGN KEY (id_empresa)
        REFERENCES empresa(id_empresa)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

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
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

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
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

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
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

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
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_oferta_reclutador FOREIGN KEY (id_reclutador)
        REFERENCES reclutador(id_reclutador)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB;

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
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

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
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_postulacion_postulante FOREIGN KEY (id_postulante)
        REFERENCES postulante(id_postulante)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

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
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;
