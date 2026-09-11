<?php

require_once __DIR__ . '/../src/bootstrap.php';

use App\Database;

header('Content-Type: application/json; charset=utf-8');

$codigo = $_GET['codigo'] ?? null;

if (!$codigo) {
    http_response_code(400);
    echo json_encode(['error' => 'codigo es requerido']);
    exit;
}

$pdo = Database::getConnection();

$stmt = $pdo->prepare(
    'SELECT id, codigo_seguimiento, estado_actual, fecha_ingreso, fecha_entrega
     FROM orden_servicio WHERE codigo_seguimiento = ?'
);
$stmt->execute([$codigo]);
$orden = $stmt->fetch();

if (!$orden) {
    http_response_code(404);
    echo json_encode(['error' => 'No se encontro una orden con ese codigo']);
    exit;
}

// Mapeo de estados internos -> estado publico (simplificado para el cliente).
// "esperando_repuestos" se agrupa con "en_reparacion" para no generar ruido.
$mapaEstadosPublicos = [
    'recibido' => 'Recibido',
    'diagnostico' => 'En reparación',
    'en_reparacion' => 'En reparación',
    'esperando_respuesta' => 'En espera de respuesta',
    'esperando_repuestos' => 'En reparación',
    'finalizado_tecnico' => 'En reparación',
    'en_revision_recepcion' => 'En reparación',
    'listo_para_entregar' => 'Listo para entregar',
    'entregado' => 'Entregado',
    'chatarra' => 'En diagnóstico',
    'no_autorizado' => 'Servicio no autorizado',
];

$stmtHistorial = $pdo->prepare(
    'SELECT estado, fecha FROM historial_estado WHERE orden_id = ? ORDER BY fecha ASC'
);
$stmtHistorial->execute([$orden['id']]);
$historial = $stmtHistorial->fetchAll();

// Diagnóstico y cotización más reciente de la orden, para que el cliente
// vea el detalle (dictamen, repuestos con su precio y el total) en su
// línea de tiempo, no solo el nombre del estado.
$stmtCotizacion = $pdo->prepare(
    'SELECT dictamen, repuestos, monto, subtotal, abono, estado, fecha_respuesta
     FROM cotizacion WHERE orden_id = ? ORDER BY id DESC LIMIT 1'
);
$stmtCotizacion->execute([$orden['id']]);
$cotizacion = $stmtCotizacion->fetch();
$cotizacionPublica = null;
if ($cotizacion) {
    $repuestos = json_decode($cotizacion['repuestos'] ?: '[]', true) ?: [];
    $cotizacionPublica = [
        'diagnostico' => $cotizacion['dictamen'],
        'repuestos' => array_map(
            static fn($r) => [
                'nombre' => $r['referencia'] ?? '',
                'cantidad' => $r['cantidad'] ?? 0,
                'precio_unitario' => $r['montoUnitario'] ?? 0,
                'precio_total' => $r['total'] ?? ((float) ($r['cantidad'] ?? 0) * (float) ($r['montoUnitario'] ?? 0)),
            ],
            $repuestos
        ),
        'total' => $cotizacion['monto'],
        'abono' => $cotizacion['abono'],
        'estado' => $cotizacion['estado'],
    ];
}

// Traducimos cada paso del historial a su version publica,
// y quitamos duplicados consecutivos (ej. dos pasos internos
// que se ven igual para el cliente no deben repetirse en la linea de tiempo).
$lineaTiempoPublica = [];
$ultimoEstadoPublico = null;

foreach ($historial as $paso) {
    if ($paso['estado'] === 'chatarra') {
        continue;
    }
    $estadoPublico = $mapaEstadosPublicos[$paso['estado']] ?? $paso['estado'];
    if ($estadoPublico !== $ultimoEstadoPublico) {
        $lineaTiempoPublica[] = [
            'estado' => $estadoPublico,
            'fecha' => $paso['fecha'],
        ];
        $ultimoEstadoPublico = $estadoPublico;
    }
}

echo json_encode([
    'codigo_seguimiento' => $orden['codigo_seguimiento'],
    'estado_actual' => $orden['estado_actual'] === 'chatarra'
        ? 'En diagnóstico'
        : ($mapaEstadosPublicos[$orden['estado_actual']] ?? $orden['estado_actual']),
    'linea_tiempo' => $lineaTiempoPublica,
    'cotizacion' => $cotizacionPublica,
]);
