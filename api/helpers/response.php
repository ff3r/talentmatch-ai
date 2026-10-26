<?php
/**
 * TalentMatch AI - Helpers de Respuesta JSON y Encabezados HTTP
 */

// Encabezados estándar de API REST y CORS
function setApiHeaders(): void {
    if (!headers_sent()) {
        header('Content-Type: application/json; charset=UTF-8');
        header('Access-Control-Allow-Origin: *');
        header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS');
        header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
    }

    // Manejar preflight OPTIONS de CORS
    if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit;
    }
}

/**
 * Retorna una respuesta JSON exitosa
 *
 * @param mixed $data Datos de respuesta
 * @param string $message Mensaje descriptivo
 * @param int $code Código HTTP
 */
function jsonSuccess($data = null, string $message = 'Operación exitosa', int $code = 200): void {
    setApiHeaders();
    http_response_code($code);
    echo json_encode([
        'success' => true,
        'message' => $message,
        'data'    => $data,
        'timestamp' => date('c')
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit;
}

/**
 * Retorna una respuesta JSON de error
 *
 * @param string $message Mensaje de error
 * @param int $code Código HTTP (400, 401, 403, 404, 500)
 * @param mixed $errors Detalles opcionales de validación
 */
function jsonError(string $message = 'Error en la solicitud', int $code = 400, $errors = null): void {
    setApiHeaders();
    http_response_code($code);
    echo json_encode([
        'success' => false,
        'message' => $message,
        'errors'  => $errors,
        'timestamp' => date('c')
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit;
}

/**
 * Obtiene el cuerpo de la petición parseado como JSON
 *
 * @return array
 */
function getJsonInput(): array {
    $raw = file_get_contents('php://input');
    if (empty($raw)) {
        return $_POST;
    }
    $decoded = json_decode($raw, true);
    return is_array($decoded) ? $decoded : [];
}
