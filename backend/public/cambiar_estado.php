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
// Mapa de transiciones permitidas: estado_actual => [estados_a_los_que_puede_pasar]
// Esta es la "máquina de estados" hecha código: si el estado pedido
// no está en la lista permitida desde el estado actual, se rechaza.
// ============================================
$transicionesPermitidas = [
    'recibido' => ['diagnostico'],
    'diagnostico' => ['cotizacion'],
    'cotizacion' => ['en_reparacion', 'devuelto_sin_reparar'],
    'en_reparacion' => ['esperando_repuestos', 'finalizado_tecnico'],
    'esperando_repuestos' => ['en_reparacion'],
    'finalizado_tecnico' => ['en_revision_recepcion'],
    'en_revision_recepcion' => ['listo_para_entregar'],
    'listo_para_entregar' => ['entregado'],
];

// Quién puede mover a cada estado nuevo (además de admin, que siempre puede)
$rolesPorEstado = [
    'diagnostico' => ['tecnico'],
    'cotizacion' => ['recepcion'],       // presencial, la registra recepción
    'en_reparacion' => ['tecnico'],
    'esperando_repuestos' => ['tecnico'],
    'finalizado_tecnico' => ['tecnico'],
    'devuelto_sin_reparar' => ['recepcion'],
    'en_revision_recepcion' => ['tecnico'],
    'listo_para_entregar' => ['recepcion'],
    'entregado' => ['recepcion'],
];

$pdo->beginTransaction();

try {
    // Bloqueamos la fila con FOR UPDATE para evitar que dos personas
    // cambien el estado de la misma orden al mismo tiempo (condición de carrera).
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

    // Actualiza el estado "resumen" en orden_servicio (para consultas rápidas)
    $stmtUpdate = $pdo->prepare('UPDATE orden_servicio SET estado_actual = ? WHERE id = ?');
    $stmtUpdate->execute([$nuevoEstado, $ordenId]);

    // Si llegó a un estado final, registra la fecha de entrega
    if ($nuevoEstado === 'entregado') {
        $pdo->prepare('UPDATE orden_servicio SET fecha_entrega = NOW() WHERE id = ?')
            ->execute([$ordenId]);
    }

    // El registro de trazabilidad: nunca se pisa el pasado, solo se agrega.
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