<?php
/**
 * TalentMatch AI - Endpoint de Convocatorias y Ofertas Laborales
 * Métodos:
 *  - GET: Listar ofertas de la empresa (con requisitos y candidatos postulados)
 *  - POST: Publicar nueva oferta laboral (Transacción atómica con requisitos)
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';

setApiHeaders();

$method = $_SERVER['REQUEST_METHOD'];

try {
    $pdo = Database::getConnection();

    // -------------------------------------------------------------
    // GET: LISTAR OFERTAS
    // -------------------------------------------------------------
    if ($method === 'GET') {
        $idEmpresa = isset($_GET['id_empresa']) ? (int)$_GET['id_empresa'] : 1;

        $stmt = $pdo->prepare("
            SELECT 
                o.id_oferta_laboral,
                o.codigo_oferta,
                o.titulo_puesto,
                o.area_puesto,
                o.descripcion,
                o.modalidad,
                o.ubicacion,
                o.anos_experiencia_minima,
                o.estado,
                o.fecha_publicacion,
                u.nombre_completo AS reclutador_asignado,
                (SELECT COUNT(*) FROM postulacion p WHERE p.id_oferta_laboral = o.id_oferta_laboral) AS total_postulantes
            FROM oferta_laboral o
            LEFT JOIN reclutador r ON o.id_reclutador = r.id_reclutador
            LEFT JOIN usuario u ON r.id_usuario = u.id_usuario
            WHERE o.id_empresa = :id_empresa
            ORDER BY o.id_oferta_laboral DESC
        ");
        $stmt->execute([':id_empresa' => $idEmpresa]);
        $ofertas = $stmt->fetchAll();

        // Cargar requisitos para cada oferta
        $reqStmt = $pdo->prepare("SELECT id_requisito_oferta, descripcion_habilidad, tipo, nivel_requerido FROM requisito_oferta WHERE id_oferta_laboral = :id_oferta");
        foreach ($ofertas as &$oferta) {
            $reqStmt->execute([':id_oferta' => $oferta['id_oferta_laboral']]);
            $oferta['requisitos'] = $reqStmt->fetchAll();
        }

        jsonSuccess($ofertas, 'Ofertas laborales obtenidas exitosamente');
    }

    // -------------------------------------------------------------
    // POST: PUBLICAR NUEVA OFERTA LABORAL
    // -------------------------------------------------------------
    if ($method === 'POST') {
        $input = getJsonInput();
        $idEmpresa = isset($input['id_empresa']) ? (int)$input['id_empresa'] : 1;
        $idReclutador = !empty($input['id_reclutador']) ? (int)$input['id_reclutador'] : null;
        $titulo = trim($input['titulo_puesto'] ?? '');
        $area = trim($input['area_puesto'] ?? 'Tecnología');
        $descripcion = trim($input['descripcion'] ?? '');
        $modalidad = trim($input['modalidad'] ?? 'Presencial');
        $ubicacion = trim($input['ubicacion'] ?? 'Lima, Perú');
        $experienciaMinima = isset($input['anos_experiencia_minima']) ? (int)$input['anos_experiencia_minima'] : 0;
        $requisitos = is_array($input['requisitos'] ?? null) ? $input['requisitos'] : [];

        if (empty($titulo)) {
            jsonError('El título del puesto es obligatorio', 400);
        }

        // Generar código de oferta único: OFE-AÑO-RANDOM
        $codigoOferta = 'OFE-' . date('Y') . '-' . strtoupper(bin2hex(random_bytes(2)));

        $pdo->beginTransaction();

        $insOferta = $pdo->prepare("
            INSERT INTO oferta_laboral (id_empresa, id_reclutador, codigo_oferta, titulo_puesto, area_puesto, descripcion, modalidad, ubicacion, anos_experiencia_minima, estado)
            VALUES (:id_empresa, :id_reclutador, :codigo, :titulo, :area, :descripcion, :modalidad, :ubicacion, :exp, 'activa')
        ");
        $insOferta->execute([
            ':id_empresa'     => $idEmpresa,
            ':id_reclutador'  => $idReclutador,
            ':codigo'         => $codigoOferta,
            ':titulo'         => $titulo,
            ':area'           => $area,
            ':descripcion'    => $descripcion,
            ':modalidad'      => $modalidad,
            ':ubicacion'      => $ubicacion,
            ':exp'            => $experienciaMinima
        ]);
        $idOferta = (int)$pdo->lastInsertId();

        // Insertar requisitos atómicos en 3FN
        if (!empty($requisitos)) {
            $insReq = $pdo->prepare("
                INSERT INTO requisito_oferta (id_oferta_laboral, descripcion_habilidad, tipo, nivel_requerido)
                VALUES (:id_oferta, :desc, :tipo, :nivel)
            ");
            foreach ($requisitos as $req) {
                $descReq = is_string($req) ? $req : ($req['descripcion'] ?? '');
                $tipoReq = is_array($req) ? ($req['tipo'] ?? 'tecnico') : 'tecnico';
                $nivelReq = is_array($req) ? ($req['nivel'] ?? 'Obligatorio') : 'Obligatorio';

                if (!empty($descReq)) {
                    $insReq->execute([
                        ':id_oferta' => $idOferta,
                        ':desc'      => $descReq,
                        ':tipo'      => $tipoReq,
                        ':nivel'     => $nivelReq
                    ]);
                }
            }
        }

        $pdo->commit();

        jsonSuccess([
            'id_oferta_laboral' => $idOferta,
            'codigo_oferta'     => $codigoOferta,
            'titulo_puesto'     => $titulo
        ], 'Oferta laboral publicada exitosamente en MySQL', 201);
    }

    jsonError('Método HTTP no soportado', 405);

} catch (PDOException $e) {
    if (isset($pdo) && $pdo->inTransaction()) {
        $pdo->rollBack();
    }
    jsonError('Error en la base de datos al gestionar ofertas', 500, ['internal' => $e->getMessage()]);
}
