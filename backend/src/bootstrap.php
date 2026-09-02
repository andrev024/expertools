<?php
 
require_once __DIR__ . '/../vendor/autoload.php';
 
// Carga las variables de .env y las deja disponibles.
$dotenv = Dotenv\Dotenv::createImmutable(__DIR__ . '/..');
$dotenv->load();
 
// Helper centralizado para leer variables de entorno.
function env(string $key, $default = null)
{
    return $_ENV[$key] ?? $_SERVER[$key] ?? (getenv($key) ?: $default);
}
 
// ============================================
// CORS: permite que el frontend (localhost:5173) hable con esta API
// (localhost:8000). Se centraliza aquí para no repetirlo en cada endpoint.
// ============================================
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PATCH, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
 
// El navegador manda una petición "OPTIONS" de prueba antes de peticiones
// con headers como Authorization o Content-Type: application/json.
// Si no respondemos algo aquí, el navegador cancela todo con "Failed to fetch".
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}
 