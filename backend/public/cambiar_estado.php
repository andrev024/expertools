<?php

require_once __DIR__ . '/../src/bootstrap.php';

use App\Database;
use App\Middleware;

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

// ============================================
// Máquina de estados v2:
// - El técnico diagnostica y cotiza (ya no recepción).
// - "cotizado" puede derivar en aprobada/rechazada/sin_respuesta.
// - Existe salida directa a "chatarra" desde el diagnóstico.
// ============================================
$transicionesPermitidas = [
    'recibido' => ['en_diagnostico'],
    'en_diagnostico' => ['chatarra', 'cotizado'],
    'cotizado' => ['en_reparacion', 'no_autorizado', 'sin_respuesta'],
    'en_reparacion' => ['esperando_repuesto', 'finalizado_tecnico'],
    'esperando_repuesto' => ['en_reparacion'],
    'finalizado_tecnico' => ['en_revision_recepcion'],
    'en_revision_recepcion' => ['listo_para_entregar'],
    'listo_para_entregar' => ['entregado'],
];

// Quién puede mover a cada estado nuevo (además de admin, que siempre puede)
$rolesPorEstado = [
    'en_diagnostico' => ['tecnico'],
    'chatarra' => ['tecnico'],
    'cotizado' => ['tecnico'],       // el tecnico es quien cotiza ahora
    'en_reparacion' => ['tecnico'],
    'no_autorizado' => ['tecnico', 'recepcion'],
    'sin_respuesta' => ['tecnico', 'recepcion'],
    'esperando_repuesto' => ['tecnico'],
    'finalizado_tecnico' => ['tecnico'],
    'en_revision_recepcion' => ['tecnico'],
    'listo_para_entregar' => ['recepcion'],
    'entregado' => ['recepcion'],
];

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
    $permitidos = $transicionesPermitidas[$estadoActual] ?? [];

    if (!in_array($nuevoEstado, $permitidos)) {
        $pdo->rollBack();
        http_response_code(422);
        echo json_encode([
            'error' => "No se puede pasar de '{$estadoActual}' a '{$nuevoEstado}'",
            'estados_permitidos_desde_aqui' => $permitidos,
        ]);
        exit;
    }

    $rolesPermitidosParaEsteEstado = $rolesPorEstado[$nuevoEstado] ?? [];
    if ($usuarioAuth->rol !== 'admin' && !in_array($usuarioAuth->rol, $rolesPermitidosParaEsteEstado)) {
        $pdo->rollBack();
        http_response_code(403);
        echo json_encode(['error' => 'Tu rol no puede realizar este cambio de estado']);
        exit;
    }

    $stmtUpdate = $pdo->prepare('UPDATE orden_servicio SET estado_actual = ? WHERE id = ?');
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
