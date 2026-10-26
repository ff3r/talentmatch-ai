-- ==============================================================================
-- SISTEMA: TALENTMATCH AI (talentmatch-ai-V2)
-- DESCRIPCION: Script DML de Inserción de Datos Semilla (Seeds)
-- MOTOR: MySQL 8.0+ / MariaDB 10.4+ (InnoDB, UTF-8 Multilingüe)
-- NOTA IMPORTANTE: Ejecutar este script ÚNICAMENTE DESPUÉS de haber ejecutado schema.sql
-- ==============================================================================

USE talentmatch_db;

-- Desactivar temporalmente chequeos durante inserción masiva controlada (buena práctica)
SET FOREIGN_KEY_CHECKS = 1;

-- ==============================================================================
-- 1. TABLA: rol
-- ==============================================================================
INSERT INTO rol (id_rol, nombre, descripcion) VALUES
(1, 'Empresa', 'Acceso al panel corporativo, gestión de ofertas de empleo y equipo de reclutadores'),
(2, 'Reclutador', 'Gestión de procesos de selección, evaluación de postulantes y matching con IA'),
(3, 'Postulante', 'Búsqueda de empleo, registro de perfil profesional, CV y seguimiento de postulaciones'),
(4, 'Administrador', 'Control maestro del sistema, gestión de catálogos y parámetros globales')
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), descripcion = VALUES(descripcion);

-- ==============================================================================
-- 2. TABLA: usuario
-- Ciberseguridad / OWASP:
-- Las contraseñas están almacenadas mediante hash bcrypt irreversible ($2y$10$...).
--
-- Credenciales de demostración para pruebas y sustentación académica:
-- +-------------------------------+-------------------+---------------+
-- | Correo Electrónico            | Rol               | Contraseña    |
-- +-------------------------------+-------------------+---------------+
-- | empresa@talentmatch.com       | Empresa (Admin)   | Empresa2026*  |
-- | reclutador@talentmatch.com    | Reclutador Senior | Reclutador2026*|
-- | postulante@talentmatch.com    | Postulante        | Postulante2026*|
-- | admin@talentmatch.com         | Administrador     | Admin2026*    |
-- | maria.invitada@techcorp.com   | Reclutador Pend.  | (Por activar) |
-- +-------------------------------+-------------------+---------------+
-- ==============================================================================
INSERT INTO usuario (id_usuario, id_rol, email, password_hash, nombre_completo, telefono, estado, token_activacion, token_expira_at) VALUES
(1, 1, 'empresa@talentmatch.com',    '$2y$10$B4zOXpnL5HYtNMRQCHsEzerx.O2Z8y.zmv2EbokYQrvYM6uSsn5LW', 'TechCorp Internacional S.A.', '+51 987654321', 'activo', NULL, NULL),
(2, 2, 'reclutador@talentmatch.com', '$2y$10$t2sBO07OuRIAPGUoh5HkGO/AbUjwAC1HuEEcgW2N7h1I54SYIdLZW', 'Ana Patricia Martinez',       '+51 912345678', 'activo', NULL, NULL),
(3, 3, 'postulante@talentmatch.com', '$2y$10$SgH9E.GupFmePm/lzRz4XO91fHb2YqTeMCRXKXoE3ztjPVRutWNh.', 'Carlos Eduardo Lopez',         '+51 998877665', 'activo', NULL, NULL),
(4, 4, 'admin@talentmatch.com',      '$2y$10$7gdt5iAO3VISqNbUeD5qbu/u0wuJOXlVcvMp0bkeCAkDPael0ljru', 'Administrador del Sistema',    '+51 900112233', 'activo', NULL, NULL),
(5, 2, 'maria.invitada@techcorp.com','$2y$10$t2sBO07OuRIAPGUoh5HkGO/AbUjwAC1HuEEcgW2N7h1I54SYIdLZW', 'María Fernanda Gómez',        NULL,            'pendiente', 'tok_act_98f7a1c4e2b0', '2026-11-01 23:59:59')
ON DUPLICATE KEY UPDATE email = VALUES(email), password_hash = VALUES(password_hash), estado = VALUES(estado);

-- ==============================================================================
-- 3. TABLA: empresa (1:1 con usuario id_usuario = 1)
-- ==============================================================================
INSERT INTO empresa (id_empresa, id_usuario, ruc, razon_social, sector_industrial, ubicacion_sede, sitio_web) VALUES
(1, 1, '20601234567', 'TechCorp Internacional S.A.', 'Tecnología y Desarrollo de Software', 'San Isidro, Lima, Perú', 'https://techcorp.example.com')
ON DUPLICATE KEY UPDATE razon_social = VALUES(razon_social), ruc = VALUES(ruc);

-- ==============================================================================
-- 4. TABLA: reclutador (1:1 con usuario, 1:N con empresa)
-- ==============================================================================
INSERT INTO reclutador (id_reclutador, id_usuario, id_empresa, numero_documento, cargo_empresa, area_departamento) VALUES
(1, 2, 1, '72345678', 'Reclutador Senior', 'Recursos Humanos y Atracción de Talento'),
(2, 5, 1, NULL,       'Reclutador',        'Recursos Humanos y Atracción de Talento')
ON DUPLICATE KEY UPDATE cargo_empresa = VALUES(cargo_empresa);

-- ==============================================================================
-- 5. TABLA: postulante (1:1 con usuario id_usuario = 3)
-- ==============================================================================
INSERT INTO postulante (id_postulante, id_usuario, numero_documento, tipo_documento, titular_profesional, resumen_biografico, anos_experiencia, url_curriculum_pdf, porcentaje_completitud) VALUES
(1, 3, '45678912', 'DNI', 'Desarrollador Full Stack & Arquitecto de Software', 'Ingeniero de Sistemas con más de 5 años diseñando aplicaciones web de alto rendimiento y soluciones escalables con IA.', 5, 'https://talentmatch.example.com/cvs/carlos-eduardo-lopez.pdf', 95.00)
ON DUPLICATE KEY UPDATE titular_profesional = VALUES(titular_profesional), porcentaje_completitud = VALUES(porcentaje_completitud);

-- ==============================================================================
-- 6. TABLA: formacion (Entidad débil de postulante)
-- ==============================================================================
INSERT INTO formacion (id_formacion, id_postulante, institucion, grado_obtenido, anio_egreso) VALUES
(1, 1, 'Universidad Nacional Mayor de San Marcos', 'Bachiller en Ingeniería de Sistemas', 2021)
ON DUPLICATE KEY UPDATE institucion = VALUES(institucion);

-- ==============================================================================
-- 7. TABLA: experiencia (Entidad débil de postulante)
-- ==============================================================================
INSERT INTO experiencia (id_experiencia, id_postulante, empresa, cargo, periodo, funciones_desempenadas) VALUES
(1, 1, 'Innovatech Latam', 'Senior Software Engineer', '2022 - Actualidad', 'Liderazgo técnico en desarrollo de microservicios, optimización de queries SQL y arquitectura frontend.')
ON DUPLICATE KEY UPDATE cargo = VALUES(cargo);

-- ==============================================================================
-- 8. TABLA: oferta_laboral (1:N con empresa, 1:N opcional con reclutador)
-- ==============================================================================
INSERT INTO oferta_laboral (id_oferta_laboral, id_empresa, id_reclutador, codigo_oferta, titulo_puesto, area_puesto, descripcion, modalidad, ubicacion, anos_experiencia_minima, estado) VALUES
(1, 1, 1, 'OFE-2026-001', 'Desarrollador Full Stack Senior', 'Tecnología', 'Buscamos un Ingeniero de Software para liderar el desarrollo de nuestros servicios cloud con PHP, MySQL y frontend reactivo.', 'Hibrido', 'Lima, Perú', 4, 'activa')
ON DUPLICATE KEY UPDATE titulo_puesto = VALUES(titulo_puesto), estado = VALUES(estado);

-- ==============================================================================
-- 9. TABLA: requisito_oferta (Entidad débil de oferta_laboral)
-- ==============================================================================
INSERT INTO requisito_oferta (id_requisito_oferta, id_oferta_laboral, descripcion_habilidad, tipo, nivel_requerido) VALUES
(1, 1, 'JavaScript / TypeScript', 'tecnico', 'Obligatorio'),
(2, 1, 'Bases de Datos Relacionales (SQL / 3FN)', 'tecnico', 'Obligatorio'),
(3, 1, 'Inglés Intermedio / Técnico', 'idioma', 'Deseable')
ON DUPLICATE KEY UPDATE descripcion_habilidad = VALUES(descripcion_habilidad);

-- ==============================================================================
-- 10. TABLA: postulacion (Resuelve N:M entre postulante y oferta_laboral)
-- ==============================================================================
INSERT INTO postulacion (id_postulacion, id_oferta_laboral, id_postulante, codigo_postulacion, fecha_postulacion, estado) VALUES
(1, 1, 1, 'POST-2026-001', CURRENT_TIMESTAMP, 'Preseleccionado')
ON DUPLICATE KEY UPDATE estado = VALUES(estado);

-- ==============================================================================
-- 11. TABLA: evaluacion_ia (1:1 con postulacion)
-- ==============================================================================
INSERT INTO evaluacion_ia (id_evaluacion_ia, id_postulacion, puntaje_matching, clasificacion, justificacion_semantica, modelo_ia_utilizado) VALUES
(1, 1, 95.00, 'Alto', 'El postulante cuenta con sólida formación en Ingeniería de Sistemas y 5 años de experiencia en desarrollo Full Stack y SQL, cumpliendo con todos los requisitos obligatorios del puesto.', 'TalentMatch-SentenceBERT-v1')
ON DUPLICATE KEY UPDATE puntaje_matching = VALUES(puntaje_matching);
