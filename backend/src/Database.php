<?php

namespace App;

use PDO;
use PDOException;

class Database
{
    private static ?PDO $instance = null;

    // Patrón Singleton: una sola conexión reutilizada en toda la petición,
    // en vez de abrir una conexión nueva cada vez que se necesita.
    public static function getConnection(): PDO
    {
        if (self::$instance === null) {
            $host = env('DB_HOST') ?: 'localhost';
            $dbname = env('DB_NAME') ?: 'taller_tracker';
            $user = env('DB_USER') ?: 'root';
            $pass = env('DB_PASS') ?: '';

            $dsn = "mysql:host={$host};dbname={$dbname};charset=utf8mb4";

            try {
                self::$instance = new PDO($dsn, $user, $pass, [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                ]);
            } catch (PDOException $e) {
                http_response_code(500);
                die(json_encode(['error' => 'Error de conexión a la base de datos']));
            }
        }

        return self::$instance;
    }
}
