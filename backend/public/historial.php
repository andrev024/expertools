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
    "SELECT h.estado, h.comentario, h.fecha, u.nombre AS usuario_nombre,
            COALESCE((SELECT GROUP_CONCAT(a.nombre SEPARATOR ', ')
                      FROM accesorio a
                      JOIN orden_servicio os2 ON os2.articulo_id = a.articulo_id
                      WHERE os2.id = h.orden_id), '') AS accesorios
     FROM historial_estado h
     LEFT JOIN usuario u ON u.id = h.usuario_id
     WHERE h.orden_id = ?
     ORDER BY h.fecha ASC"
);
try {
    $stmt->execute([$ordenId]);
} catch (\Exception $e) {
    error_log('Error al consultar historial: ' . $e->getMessage());
    http_response_code(500);
    $mensaje = str_contains($e->getMessage(), 'accesorio')
        ? 'Falta ejecutar migration_v3.sql en la base de datos'
        : 'No se pudo obtener el historial de la orden';
    echo json_encode(['error' => $mensaje]);
    exit;
}

$historial = $stmt->fetchAll();
foreach ($historial as &$paso) {
    if ($paso['estado'] === 'recibido') {
        $paso['comentario'] = preg_replace('/\.?\s*Ubicacion:\s*.*?(?=\.?\s*Accesorios:|$)/i', '', (string) $paso['comentario']);
        if ($paso['accesorios'] !== '' && stripos($paso['comentario'], 'accesorios:') === false) {
            $paso['comentario'] = rtrim($paso['comentario'], '.')
                . '. Accesorios: ' . $paso['accesorios'];
        }
        $paso['comentario'] = trim($paso['comentario']);
    }
    unset($paso['accesorios']);
}
unset($paso);

echo json_encode($historial);
