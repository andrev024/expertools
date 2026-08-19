<?php

require_once __DIR__ . '/../src/bootstrap.php';

use App\Database;
use App\Middleware;

header('Content-Type: application/json');

Middleware::requireAuth(['recepcion', 'tecnico', 'admin']);

$pdo = Database::getConnection();

$ordenId = $_GET['orden_id'] ?? null;

if (!$ordenId) {
    http_response_code(400);
    echo json_encode(['error' => 'orden_id es requerido']);
    exit;
}

$stmt = $pdo->prepare(
    'SELECT h.estado, h.comentario, h.fecha, u.nombre AS usuario_nombre
     FROM historial_estado h
     JOIN usuario u ON u.id = h.usuario_id
     WHERE h.orden_id = ?
     ORDER BY h.fecha ASC'
);
$stmt->execute([$ordenId]);

echo json_encode($stmt->fetchAll());
