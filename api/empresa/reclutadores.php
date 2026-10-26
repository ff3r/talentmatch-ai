<?php
/**
 * TalentMatch AI - Endpoint de Gestión de Reclutadores para la Empresa
 * Métodos:
 *  - GET: Listar reclutadores de la empresa
 *  - POST: Invitar nuevo reclutador (Crea usuario pendiente y registro en reclutador)
 *  - PATCH: Alternar estado (activo / inactivo)
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';

setApiHeaders();

$method = $_SERVER['REQUEST_METHOD'];

try {
    $pdo = Database::getConnection();

    // -------------------------------------------------------------
    // GET: LISTAR RECLUTADORES
    // -------------------------------------------------------------
    if ($method === 'GET') {
        $idEmpresa = isset($_GET['id_empresa']) ? (int)$_GET['id_empresa'] : 1; // Default a empresa 1

        $stmt = $pdo->prepare("
            SELECT 
                r.id_reclutador,
                r.id_empresa,
                r.numero_documento,
                r.cargo_empresa,
                r.area_departamento,
                u.id_usuario,
                u.email,
                u.nombre_completo,
                u.estado,
                u.created_at,
                (SELECT COUNT(*) FROM oferta_laboral o WHERE o.id_reclutador = r.id_reclutador AND o.estado = 'activa') AS ofertas_activas
            FROM reclutador r
            INNER JOIN usuario u ON r.id_usuario = u.id_usuario
            WHERE r.id_empresa = :id_empresa
            ORDER BY u.id_usuario DESC
        ");
        $stmt->execute([':id_empresa' => $idEmpresa]);
        $reclutadores = $stmt->fetchAll();

        jsonSuccess($reclutadores, 'Equipo de reclutadores obtenido con éxito');
    }

    // -------------------------------------------------------------
    // POST: INVITAR RECLUTADOR
    // -------------------------------------------------------------
    if ($method === 'POST') {
        $input = getJsonInput();
        $nombre = trim($input['nombre'] ?? '');
        $email = trim($input['email'] ?? '');
        $cargo = trim($input['cargo'] ?? 'Reclutador');
        $idEmpresa = isset($input['id_empresa']) ? (int)$input['id_empresa'] : 1;

        if (empty($nombre) || empty($email)) {
            jsonError('Nombre completo y correo electrónico son obligatorios', 400);
        }

        // Verificar si ya existe el correo
        $check = $pdo->prepare("SELECT id_usuario FROM usuario WHERE email = :email LIMIT 1");
        $check->execute([':email' => $email]);
        if ($check->fetch()) {
            jsonError('Ya existe un usuario registrado con este correo electrónico', 409);
        }

        // Generar token criptográfico seguro de activación
        $token = bin2hex(random_bytes(16));
        $expiraAt = date('Y-m-d H:i:s', strtotime('+48 hours'));

        // Contraseña provisional temporal aleatoria
        $tempHash = password_hash(bin2hex(random_bytes(8)), PASSWORD_BCRYPT);

        $pdo->beginTransaction();

        // 1. Insertar en usuario (rol = 2: Reclutador, estado = 'pendiente')
        $insUser = $pdo->prepare("
            INSERT INTO usuario (id_rol, email, password_hash, nombre_completo, estado, token_activacion, token_expira_at)
            VALUES (2, :email, :hash, :nombre, 'pendiente', :token, :expira)
        ");
        $insUser->execute([
            ':email'  => $email,
            ':hash'   => $tempHash,
            ':nombre' => $nombre,
            ':token'  => $token,
            ':expira' => $expiraAt
        ]);
        $idUsuario = (int)$pdo->lastInsertId();

        // 2. Insertar en reclutador
        $insRec = $pdo->prepare("
            INSERT INTO reclutador (id_usuario, id_empresa, numero_documento, cargo_empresa, area_departamento)
            VALUES (:id_usuario, :id_empresa, NULL, :cargo, 'Recursos Humanos y Atracción de Talento')
        ");
        $insRec->execute([
            ':id_usuario' => $idUsuario,
            ':id_empresa' => $idEmpresa,
            ':cargo'      => $cargo
        ]);
        $idReclutador = (int)$pdo->lastInsertId();

        $pdo->commit();

        jsonSuccess([
            'id_usuario'       => $idUsuario,
            'id_reclutador'    => $idReclutador,
            'nombre'           => $nombre,
            'email'            => $email,
            'estado'           => 'pendiente',
            'token_activacion' => $token,
            'link_activacion'  => "auth/activar-cuenta.html?token={$token}&email=" . urlencode($email) . "&nombre=" . urlencode($nombre)
        ], 'Invitación de reclutador registrada exitosamente en la base de datos', 201);
    }

    // -------------------------------------------------------------
    // PATCH: CAMBIAR ESTADO (ACTIVAR / DESACTIVAR)
    // -------------------------------------------------------------
    if ($method === 'PATCH') {
        $input = getJsonInput();
        $idUsuario = isset($input['id_usuario']) ? (int)$input['id_usuario'] : 0;
        $nuevoEstado = trim($input['estado'] ?? '');

        if (!$idUsuario || !in_array($nuevoEstado, ['activo', 'inactivo'])) {
            jsonError('ID de usuario y nuevo estado válido (activo/inactivo) son requeridos', 400);
        }

        $stmt = $pdo->prepare("UPDATE usuario SET estado = :estado WHERE id_usuario = :id");
        $stmt->execute([
            ':estado' => $nuevoEstado,
            ':id'     => $idUsuario
        ]);

        jsonSuccess([
            'id_usuario' => $idUsuario,
            'nuevo_estado' => $nuevoEstado
        ], "Estado del reclutador actualizado a '{$nuevoEstado}'");
    }

    jsonError('Método HTTP no soportado', 405);

} catch (PDOException $e) {
    if (isset($pdo) && $pdo->inTransaction()) {
        $pdo->rollBack();
    }
    jsonError('Error en la base de datos al gestionar reclutadores', 500, ['internal' => $e->getMessage()]);
}
