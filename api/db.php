<?php
/**
 * TalentMatch AI - Punto de Entrada y Diagnóstico de Conexión de Base de Datos
 * Puede incluirse en otros scripts o llamarse directamente vía GET /api/db.php para testear la conexión.
 */

require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/helpers/response.php';

// Si se accede directamente a este archivo vía navegador o curl, responder con diagnóstico de salud
if (basename($_SERVER['SCRIPT_FILENAME'] ?? '') === 'db.php') {
    setApiHeaders();
    try {
        $pdo = Database::getConnection();
        
        // Obtener versión de MySQL y conteo de tablas
        $versionStmt = $pdo->query("SELECT VERSION() as version, DATABASE() as db");
        $serverInfo = $versionStmt->fetch();

        $tablesStmt = $pdo->query("SHOW TABLES");
        $tables = $tablesStmt->fetchAll(PDO::FETCH_COLUMN);

        jsonSuccess([
            'database' => $serverInfo['db'],
            'version'  => $serverInfo['version'],
            'charset'  => 'utf8mb4',
            'tables_count' => count($tables),
            'tables'   => $tables
        ], 'Conexión a la base de datos establecida con éxito mediante PDO');
    } catch (PDOException $e) {
        jsonError('No se pudo conectar a la base de datos MySQL', 500, [
            'error' => $e->getMessage(),
            'hint'  => 'Asegúrate de que MySQL esté iniciado (puerto 3306) y que la base de datos talentmatch_db haya sido creada con schema.sql'
        ]);
    }
}
