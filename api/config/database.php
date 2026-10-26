<?php
class Database {
    private static ?PDO $instance = null;

    private static string $host = '127.0.0.1';
    private static string $port = '3306';
    private static string $dbName = 'talentmatch_db';
    private static string $user = 'root';
    private static string $password = '';

    /**
     * Obtiene la instancia única de conexión PDO (Patrón Singleton)
     *
     * @return PDO
     * @throws PDOException
     */
    public static function getConnection(): PDO {
        if (self::$instance === null) {
            // Permitir sobreescritura mediante variables de entorno si existen
            $host = getenv('DB_HOST') ?: self::$host;
            $port = getenv('DB_PORT') ?: self::$port;
            $dbName = getenv('DB_NAME') ?: self::$dbName;
            $user = getenv('DB_USER') ?: self::$user;
            $password = getenv('DB_PASS') !== false ? getenv('DB_PASS') : self::$password;

            $dsn = "mysql:host={$host};port={$port};dbname={$dbName};charset=utf8mb4";

            $options = [
                // 1. Manejo estricto de excepciones para capturar errores de integridad referencial
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                // 2. Retorno de resultados como arreglos asociativos limpios
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                // 3. Sentencias preparadas nativas en el motor (desactiva emulación para máxima seguridad OWASP)
                PDO::ATTR_EMULATE_PREPARES   => false,
                // 4. Conexión persistente desactivada por defecto para evitar bloqueos en servidores locales
                PDO::ATTR_PERSISTENT         => false,
            ];

            try {
                self::$instance = new PDO($dsn, $user, $password, $options);
            } catch (PDOException $e) {
                // Log interno y relanzar para manejo en capa de respuesta JSON
                error_log("Error de conexión a la base de datos: " . $e->getMessage());
                throw $e;
            }
        }

        return self::$instance;
    }

    /**
     * Cierra explícitamente la conexión activa
     */
    public static function closeConnection(): void {
        self::$instance = null;
    }
}
