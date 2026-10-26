<?php
/**
 * TalentMatch AI - Endpoint de Autenticación (Login)
 * Método: POST
 * Body JSON: { "email": "...", "password": "..." }
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';

setApiHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Método no permitido. Utilice POST', 405);
}

$input = getJsonInput();
$email = trim($input['email'] ?? '');
$password = trim($input['password'] ?? '');

if (empty($email) || empty($password)) {
    jsonError('Correo electrónico y contraseña son obligatorios', 400);
}

try {
    $pdo = Database::getConnection();

    // 1. Buscar usuario por correo electrónico uniendo su rol
    $stmt = $pdo->prepare("
        SELECT 
            u.id_usuario,
            u.id_rol,
            u.email,
            u.password_hash,
            u.nombre_completo,
            u.telefono,
            u.estado,
            r.nombre AS rol_nombre
        FROM usuario u
        INNER JOIN rol r ON u.id_rol = r.id_rol
        WHERE u.email = :email
        LIMIT 1
    ");
    $stmt->execute([':email' => $email]);
    $user = $stmt->fetch();

    if (!$user) {
        jsonError('Credenciales incorrectas. Verifique correo y contraseña', 401);
    }

    // 2. Verificar estado de la cuenta
    if ($user['estado'] === 'inactivo') {
        jsonError('Esta cuenta se encuentra desactivada. Contacte con el administrador', 403);
    }

    if ($user['estado'] === 'pendiente') {
        jsonError('Esta cuenta aún no ha sido activada. Por favor revise el correo de invitación', 403);
    }

    // 3. Verificación criptográfica con bcrypt
    if (!password_verify($password, $user['password_hash'])) {
        jsonError('Credenciales incorrectas. Verifique correo y contraseña', 401);
    }

    // 4. Cargar perfil complementario según rol
    $profileData = [];
    $redirectUrl = '';

    switch (strtolower($user['rol_nombre'])) {
        case 'empresa':
            $empStmt = $pdo->prepare("SELECT id_empresa, ruc, razon_social, sector_industrial, ubicacion_sede FROM empresa WHERE id_usuario = :id LIMIT 1");
            $empStmt->execute([':id' => $user['id_usuario']]);
            $profileData = $empStmt->fetch() ?: [];
            $redirectUrl = 'empresa/dashboard.html';
            break;

        case 'reclutador':
            $recStmt = $pdo->prepare("
                SELECT r.id_reclutador, r.id_empresa, r.numero_documento, r.cargo_empresa, r.area_departamento, e.razon_social as empresa_nombre
                FROM reclutador r
                INNER JOIN empresa e ON r.id_empresa = e.id_empresa
                WHERE r.id_usuario = :id LIMIT 1
            ");
            $recStmt->execute([':id' => $user['id_usuario']]);
            $profileData = $recStmt->fetch() ?: [];
            $redirectUrl = 'reclutador/dashboard.html';
            break;

        case 'postulante':
            $postStmt = $pdo->prepare("SELECT id_postulante, numero_documento, titular_profesional, anos_experiencia, porcentaje_completitud FROM postulante WHERE id_usuario = :id LIMIT 1");
            $postStmt->execute([':id' => $user['id_usuario']]);
            $profileData = $postStmt->fetch() ?: [];
            $redirectUrl = 'postulante/dashboard.html';
            break;

        case 'administrador':
            $redirectUrl = 'admin/dashboard.html';
            break;
    }

    // Eliminar hash por seguridad en la respuesta
    unset($user['password_hash']);

    jsonSuccess([
        'user'     => $user,
        'profile'  => $profileData,
        'redirect' => $redirectUrl
    ], 'Inicio de sesión exitoso');

} catch (PDOException $e) {
    jsonError('Error al procesar la autenticación en la base de datos', 500, ['internal' => $e->getMessage()]);
}
