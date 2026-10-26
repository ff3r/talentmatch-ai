<?php
/**
 * TalentMatch AI - Endpoint de Activación de Cuenta de Reclutador
 * Método: POST
 * Body JSON: { "email": "...", "numero_documento": "...", "password": "...", "token": "..." }
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';

setApiHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Método no permitido. Utilice POST', 405);
}

$input = getJsonInput();
$email = trim($input['email'] ?? '');
$dni = trim($input['numero_documento'] ?? '');
$password = trim($input['password'] ?? '');
$token = trim($input['token'] ?? '');

if (empty($email) || empty($password) || empty($dni)) {
    jsonError('Correo electrónico, documento de identidad y contraseña son obligatorios', 400);
}

if (strlen($password) < 6) {
    jsonError('La contraseña debe tener al menos 6 caracteres', 400);
}

try {
    $pdo = Database::getConnection();

    // 1. Buscar usuario pendiente por email
    $stmt = $pdo->prepare("SELECT id_usuario, estado, token_activacion FROM usuario WHERE email = :email LIMIT 1");
    $stmt->execute([':email' => $email]);
    $user = $stmt->fetch();

    if (!$user) {
        jsonError('No existe ningún usuario registrado con ese correo electrónico', 404);
    }

    if ($user['estado'] === 'activo') {
        jsonError('Esta cuenta ya ha sido activada previamente. Puede iniciar sesión directamente', 400);
    }

    // 2. Generar hash bcrypt estándar de la nueva contraseña
    $passwordHash = password_hash($password, PASSWORD_BCRYPT);

    $pdo->beginTransaction();

    // 3. Actualizar tabla usuario
    $updUser = $pdo->prepare("
        UPDATE usuario 
        SET password_hash = :hash, 
            estado = 'activo', 
            token_activacion = NULL,
            token_expira_at = NULL
        WHERE id_usuario = :id
    ");
    $updUser->execute([
        ':hash' => $passwordHash,
        ':id'   => $user['id_usuario']
    ]);

    // 4. Actualizar DNI en la tabla reclutador
    $updRec = $pdo->prepare("
        UPDATE reclutador 
        SET numero_documento = :dni 
        WHERE id_usuario = :id
    ");
    $updRec->execute([
        ':dni' => $dni,
        ':id'  => $user['id_usuario']
    ]);

    $pdo->commit();

    jsonSuccess([
        'email'    => $email,
        'redirect' => 'reclutador/dashboard.html'
    ], 'Cuenta activada exitosamente. Ahora puede acceder a su panel');

} catch (PDOException $e) {
    if (isset($pdo) && $pdo->inTransaction()) {
        $pdo->rollBack();
    }
    jsonError('Error al activar la cuenta en la base de datos', 500, ['internal' => $e->getMessage()]);
}
