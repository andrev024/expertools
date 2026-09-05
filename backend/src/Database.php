<?php

namespace App;

use PDO;
use PDOException;

class Database
{
    private static ?PDO $instance = null;

    public static function getConnection(): PDO
    {
        if (self::$instance === null) {
            $host = env('DB_HOST', 'localhost');
            $port = env('DB_PORT', '3306');
            $dbname = env('DB_NAME', 'taller_tracker');
            $user = env('DB_USER', 'root');
            $pass = env('DB_PASS', '');

            $dsn = "mysql:host={$host};port={$port};dbname={$dbname};charset=utf8mb4";

            $opciones = [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            ];

            // Aiven (y muchos proveedores de nube) exigen conexion SSL a la base
            // de datos. Si existe el certificado CA, lo usamos; en local
            // (tu XAMPP, sin SSL) simplemente no existira ese archivo y se ignora,
            // conectando normal sin SSL.
            $rutaCertificado = env('DB_SSL_CA_PATH');
            if ($rutaCertificado && file_exists($rutaCertificado)) {
                $opciones[PDO::MYSQL_ATTR_SSL_CA] = $rutaCertificado;
            }

            try {
                self::$instance = new PDO($dsn, $user, $pass, $opciones);
            } catch (PDOException $e) {
                http_response_code(500);
                die(json_encode(['error' => 'Error de conexión a la base de datos']));
            }
        }

        return self::$instance;
    }
}
