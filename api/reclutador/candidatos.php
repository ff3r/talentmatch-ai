<?php
/**
 * TalentMatch AI - Endpoint de Candidatos para Reclutadores
 * Método: GET
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';

setApiHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonError('Método no permitido', 405);
}

try {
    $pdo = Database::getConnection();

    $stmt = $pdo->query("
        SELECT 
            p.id_postulante,
            p.numero_documento,
            p.tipo_documento,
            p.titular_profesional,
            p.resumen_biografico,
            p.anos_experiencia,
            p.porcentaje_completitud,
            p.url_curriculum_pdf,
            u.id_usuario,
            u.nombre_completo,
            u.email,
            u.telefono,
            u.estado
        FROM postulante p
        INNER JOIN usuario u ON p.id_usuario = u.id_usuario
        ORDER BY p.id_postulante DESC
    ");
    $candidatos = $stmt->fetchAll();

    // Obtener formaciones y experiencias
    $formStmt = $pdo->prepare("SELECT institucion, grado_obtenido, anio_egreso FROM formacion WHERE id_postulante = :id");
    $expStmt = $pdo->prepare("SELECT empresa, cargo, periodo, funciones_desempenadas FROM experiencia WHERE id_postulante = :id");

    foreach ($candidatos as &$cand) {
        $formStmt->execute([':id' => $cand['id_postulante']]);
        $cand['formacion'] = $formStmt->fetchAll();

        $expStmt->execute([':id' => $cand['id_postulante']]);
        $cand['experiencia'] = $expStmt->fetchAll();
    }

    jsonSuccess($candidatos, 'Candidatos obtenidos exitosamente');

} catch (PDOException $e) {
    jsonError('Error al consultar candidatos', 500, ['internal' => $e->getMessage()]);
}
