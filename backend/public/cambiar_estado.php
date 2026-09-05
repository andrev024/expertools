<?php

require_once __DIR__ . '/../src/bootstrap.php';

use App\Database;
use App\Middleware;
use App\MaquinaEstados;

header('Content-Type: application/json');

$usuarioAuth = Middleware::requireAuth(['tecnico', 'recepcion', 'admin']);

$pdo = Database::getConnection();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Método no permitido']);
    exit;
}

$datos = json_decode(file_get_contents('php://input'), true);

$ordenId = $datos['orden_id'] ?? null;
$nuevoEstado = $datos['estado'] ?? null;
$comentario = $datos['comentario'] ?? '';

if (!$ordenId || !$nuevoEstado) {
    http_response_code(400);
    echo json_encode(['error' => 'orden_id y estado son requeridos']);
    exit;
}

$pdo->beginTransaction();

try {
    $stmt = $pdo->prepare('SELECT estado_actual FROM orden_servicio WHERE id = ? FOR UPDATE');
    $stmt->execute([$ordenId]);
    $orden = $stmt->fetch();

    if (!$orden) {
        $pdo->rollBack();
        http_response_code(404);
        echo json_encode(['error' => 'Orden no encontrada']);
        exit;
    }

    $estadoActual = $orden['estado_actual'];

    // Toda la logica de "que se puede y quien puede" ahora vive en MaquinaEstados,
    // que ya esta probada por separado con PHPUnit (no depende de la base de datos).
    if (!MaquinaEstados::esTransicionValida($estadoActual, $nuevoEstado)) {
        $pdo->rollBack();
        http_response_code(422);
        echo json_encode([
            'error' => "No se puede pasar de '{$estadoActual}' a '{$nuevoEstado}'",
            'estados_permitidos_desde_aqui' => MaquinaEstados::estadosPermitidosDesde($estadoActual),
        ]);
        exit;
    }

    if (!MaquinaEstados::rolPuedeTransicionar($usuarioAuth->rol, $nuevoEstado)) {
        $pdo->rollBack();
        http_response_code(403);
        echo json_encode(['error' => 'Tu rol no puede realizar este cambio de estado']);
        exit;
    }

    if ($estadoActual === 'sin_respuesta' && $nuevoEstado === 'en_diagnostico') {
        $stmtUpdate = $pdo->prepare(
            'UPDATE orden_servicio SET estado_actual = ?, intentos_contacto_cliente = 0 WHERE id = ?'
        );
    } else {
        $stmtUpdate = $pdo->prepare('UPDATE orden_servicio SET estado_actual = ? WHERE id = ?');
    }
    $stmtUpdate->execute([$nuevoEstado, $ordenId]);

    if ($nuevoEstado === 'entregado') {
        $pdo->prepare('UPDATE orden_servicio SET fecha_entrega = NOW() WHERE id = ?')
            ->execute([$ordenId]);
    }

    $stmtHistorial = $pdo->prepare(
        'INSERT INTO historial_estado (orden_id, estado, comentario, usuario_id)
         VALUES (?, ?, ?, ?)'
    );
    $stmtHistorial->execute([$ordenId, $nuevoEstado, $comentario, $usuarioAuth->sub]);

    $pdo->commit();

    echo json_encode([
        'orden_id' => $ordenId,
        'estado_anterior' => $estadoActual,
        'estado_nuevo' => $nuevoEstado,
    ]);
} catch (\Exception $e) {
    $pdo->rollBack();
    http_response_code(500);
    echo json_encode(['error' => 'No se pudo actualizar el estado']);
}
