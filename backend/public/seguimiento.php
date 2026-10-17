<?php

require_once __DIR__ . '/../src/bootstrap.php';

use App\Database;

header('Content-Type: application/json; charset=utf-8');

$codigo = trim($_GET['codigo'] ?? '');
$ferreteriaSlug = trim($_GET['ferreteria'] ?? '');

if (!$codigo) {
    http_response_code(400);
    echo json_encode(['error' => 'codigo es requerido']);
    exit;
}

$pdo = Database::getConnection();

// Los códigos numéricos se mantienen para compatibilidad; si el enlace incluye
// una ferretería, usamos el prefijo configurado para esa cuenta.
if (preg_match('/^\d+$/', $codigo)) {
    if ($ferreteriaSlug !== '') {
        $stmtPrefijo = $pdo->prepare('SELECT codigo_prefijo FROM ferreteria WHERE slug = ?');
        $stmtPrefijo->execute([$ferreteriaSlug]);
        $prefijo = $stmtPrefijo->fetchColumn();
        if (!$prefijo) {
            http_response_code(404);
            echo json_encode(['error' => 'Ferretería no encontrada']);
            exit;
        }
    } else {
        $prefijo = $pdo->query('SELECT codigo_prefijo FROM ferreteria WHERE id = 1')->fetchColumn() ?: 'OT-A-';
    }
    $codigo = $prefijo . str_pad($codigo, 4, '0', STR_PAD_LEFT);
} else {
    $codigo = strtoupper($codigo);
}

if ($ferreteriaSlug !== '') {
    $stmt = $pdo->prepare(
        'SELECT os.id, os.codigo_seguimiento, os.estado_actual, os.fecha_ingreso,
                os.fecha_entrega, f.slug AS ferreteria_slug,
                f.nombre_comercial AS ferreteria_nombre
         FROM orden_servicio os
         JOIN ferreteria f ON f.id = os.ferreteria_id
         WHERE os.codigo_seguimiento = ? AND f.slug = ?'
    );
    $stmt->execute([$codigo, $ferreteriaSlug]);
    $ordenes = $stmt->fetchAll();
} else {
    $stmt = $pdo->prepare(
        'SELECT os.id, os.codigo_seguimiento, os.estado_actual, os.fecha_ingreso,
                os.fecha_entrega, f.slug AS ferreteria_slug,
                f.nombre_comercial AS ferreteria_nombre
         FROM orden_servicio os
         JOIN ferreteria f ON f.id = os.ferreteria_id
         WHERE os.codigo_seguimiento = ?
         LIMIT 2'
    );
    $stmt->execute([$codigo]);
    $ordenes = $stmt->fetchAll();
}

if (count($ordenes) > 1) {
    http_response_code(409);
    echo json_encode(['error' => 'Este código existe en varias ferreterías. Usa el enlace completo recibido.']);
    exit;
}
$orden = $ordenes[0] ?? null;

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
    'ferreteria_slug' => $orden['ferreteria_slug'],
    'ferreteria_nombre' => $orden['ferreteria_nombre'],
    'estado_actual' => $orden['estado_actual'] === 'chatarra'
        ? 'En diagnóstico'
        : ($mapaEstadosPublicos[$orden['estado_actual']] ?? $orden['estado_actual']),
    'linea_tiempo' => $lineaTiempoPublica,
    'cotizacion' => $cotizacionPublica,
]);
