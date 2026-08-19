<?php

require_once __DIR__ . '/../vendor/autoload.php';

// Carga las variables de .env y las deja disponibles.
$dotenv = Dotenv\Dotenv::createImmutable(__DIR__ . '/..');
$dotenv->load();

// Helper centralizado para leer variables de entorno.
// getenv() a veces no ve lo que phpdotenv carga (depende de la config
// del servidor), así que revisamos $_ENV primero como respaldo confiable.
function env(string $key, $default = null)
{
    return $_ENV[$key] ?? $_SERVER[$key] ?? (getenv($key) ?: $default);
}