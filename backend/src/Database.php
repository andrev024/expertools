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
            $driver = strtolower((string) env('DB_DRIVER', 'mysql'));
            $host = env('DB_HOST', 'localhost');
            $port = env('DB_PORT', $driver === 'pgsql' ? '5432' : '3306');
            $dbname = env('DB_NAME', 'taller_tracker');
            $user = env('DB_USER', 'root');
            $pass = env('DB_PASS', '');
            $rutaCertificado = env('DB_SSL_CA_PATH');

            if (!in_array($driver, ['mysql', 'pgsql'], true)) {
                throw new \RuntimeException('DB_DRIVER debe ser mysql o pgsql.');
            }
            if (!in_array($driver, PDO::getAvailableDrivers(), true)) {
                throw new \RuntimeException("El controlador PDO '{$driver}' no está instalado.");
            }

            $opciones = [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            ];

            if ($driver === 'mysql') {
                $dsn = "mysql:host={$host};port={$port};dbname={$dbname};charset=utf8mb4";
                if ($rutaCertificado && file_exists($rutaCertificado)) {
                    $opciones[PDO::MYSQL_ATTR_SSL_CA] = $rutaCertificado;
                }
            } else {
                $dsn = "pgsql:host={$host};port={$port};dbname={$dbname}";
                $modoSsl = env('DB_SSL_MODE', 'require');
                $dsn .= ";sslmode={$modoSsl}";

                if ($rutaCertificado) {
                    if (!file_exists($rutaCertificado)) {
                        throw new \RuntimeException('No se encontró el certificado CA configurado en DB_SSL_CA_PATH.');
                    }
                    $dsn .= ";sslrootcert={$rutaCertificado}";
                }
            }

            try {
                self::$instance = new PDO($dsn, $user, $pass, $opciones);
                self::$instance->exec(
                    $driver === 'pgsql'
                        ? "SET TIME ZONE 'America/Bogota'"
                        : "SET time_zone = '-05:00'"
                );
            } catch (PDOException $e) {
                if (PHP_SAPI === 'cli') {
                    throw $e;
                }
                http_response_code(500);
                die(json_encode(['error' => 'Error de conexión a la base de datos']));
            }
        }

        return self::$instance;
    }

    public static function getLastInsertId(PDO $pdo, string $table): string|false
    {
        if ($pdo->getAttribute(PDO::ATTR_DRIVER_NAME) === 'pgsql') {
            $stmt = $pdo->prepare('SELECT currval(pg_get_serial_sequence(?, ?))');
            $stmt->execute([$table, 'id']);
            $id = $stmt->fetchColumn();
            return $id === false || $id === null ? false : (string) $id;
        }

        return $pdo->lastInsertId();
    }
}
