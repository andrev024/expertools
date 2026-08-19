<?php

require_once __DIR__ . '/../src/bootstrap.php';

use App\Database;
use App\Middleware;

header('Content-Type: application/json');

// Solo recepcion (o admin) puede crear ordenes.
// $usuarioAuth trae el "sub" (id) y "rol" del token, ya verificado.
$usuarioAuth = Middleware::requireAuth(['recepcion', 'admin']);

$pdo = Database::getConnection();
$metodo = $_SERVER['REQUEST_METHOD'];

if ($metodo === 'POST') {
    crearOrden($pdo, $usuarioAuth);
} elseif ($metodo === 'GET') {
    listarOrdenes($pdo);
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Método no permitido']);
}

function crearOrden(\PDO $pdo, object $usuarioAuth): void
{
    $datos = json_decode(file_get_contents('php://input'), true);

    $articuloId = $datos['articulo_id'] ?? null;
    $tipo = $datos['tipo'] ?? 'mantenimiento';
    $ordenOriginalId = $datos['orden_original_id'] ?? null;

    if (!$articuloId) {
        http_response_code(400);
        echo json_encode(['error' => 'articulo_id es requerido']);
        return;
    }

    // Codigo de seguimiento simple y legible: TAL-A1B2C3
    $codigoSeguimiento = 'TAL-' . strtoupper(substr(bin2hex(random_bytes(4)), 0, 6));

    // Empezamos una transaccion: si algo falla a mitad de camino,
    // no queremos una orden creada sin su registro de historial.
    $pdo->beginTransaction();

    try {
        $stmt = $pdo->prepare(
            'INSERT INTO orden_servicio
                (codigo_seguimiento, articulo_id, tipo, orden_original_id, estado_actual)
             VALUES (?, ?, ?, ?, "recibido")'
        );
        $stmt->execute([$codigoSeguimiento, $articuloId, $tipo, $ordenOriginalId]);
        $ordenId = $pdo->lastInsertId();

        // Primer registro de trazabilidad: siempre se crea al nacer la orden.
        $stmtHistorial = $pdo->prepare(
            'INSERT INTO historial_estado (orden_id, estado, comentario, usuario_id)
             VALUES (?, "recibido", "Articulo recibido en recepcion", ?)'
        );
        $stmtHistorial->execute([$ordenId, $usuarioAuth->sub]);

        $pdo->commit();

        http_response_code(201);
        echo json_encode([
            'id' => $ordenId,
            'codigo_seguimiento' => $codigoSeguimiento,
            'estado_actual' => 'recibido',
        ]);
    } catch (\Exception $e) {
        $pdo->rollBack();
        http_response_code(500);
        echo json_encode(['error' => 'No se pudo crear la orden']);
    }
}

function listarOrdenes(\PDO $pdo): void
{
    $stmt = $pdo->query(
        'SELECT os.id, os.codigo_seguimiento, os.tipo, os.estado_actual, os.fecha_ingreso,
                a.tipo AS articulo_tipo, a.marca, a.modelo,
                c.nombre AS cliente_nombre
         FROM orden_servicio os
         JOIN articulo a ON a.id = os.articulo_id
         JOIN cliente c ON c.id = a.cliente_id
         ORDER BY os.fecha_ingreso DESC'
    );

    echo json_encode($stmt->fetchAll());
}
