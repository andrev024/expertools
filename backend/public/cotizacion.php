<?php

require_once __DIR__ . '/../src/bootstrap.php';

use App\Database;
use App\Middleware;

header('Content-Type: application/json; charset=utf-8');

$usuarioAuth = Middleware::requireAuth(['tecnico', 'recepcion', 'admin']);

$pdo = Database::getConnection();
$metodo = $_SERVER['REQUEST_METHOD'];

if ($metodo === 'POST') {
    registrarCotizacion($pdo, $usuarioAuth);
} elseif ($metodo === 'PUT') {
    editarRepuestos($pdo, $usuarioAuth);
} elseif ($metodo === 'PATCH') {
    responderCotizacion($pdo, $usuarioAuth);
} elseif ($metodo === 'GET') {
    obtenerCotizacion($pdo);
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Método no permitido']);
}

function obtenerCotizacion(\PDO $pdo): void
{
    $ordenId = $_GET['orden_id'] ?? null;
    if (!$ordenId) {
        http_response_code(400);
        echo json_encode(['error' => 'orden_id es requerido']);
        return;
    }

    $stmt = $pdo->prepare(
        'SELECT repuestos, dictamen, monto, subtotal, abono, estado
         FROM cotizacion WHERE orden_id = ? ORDER BY id DESC LIMIT 1'
    );
    $stmt->execute([$ordenId]);
    $cotizacion = $stmt->fetch();

    if (!$cotizacion) {
        http_response_code(404);
        echo json_encode(['error' => 'La orden no tiene una cotización registrada']);
        return;
    }

    $cotizacion['repuestos'] = json_decode($cotizacion['repuestos'] ?: '[]', true) ?: [];
    echo json_encode($cotizacion, JSON_UNESCAPED_UNICODE);
}

function registrarCotizacion(\PDO $pdo, object $usuarioAuth): void
{
    $datos = json_decode(file_get_contents('php://input'), true);

    $ordenId = $datos['orden_id'] ?? null;
    $repuestos = $datos['repuestos'] ?? null;
    $dictamen = $datos['dictamen'] ?? null;
    $abono = max(0, (float) ($datos['abono'] ?? 0));

    $listaRepuestos = json_decode($repuestos ?: '[]', true);
    if (!is_array($listaRepuestos)) {
        $listaRepuestos = [];
    }
    $subtotal = 0;
    foreach ($listaRepuestos as &$repuesto) {
        $cantidad = (int) ($repuesto['cantidad'] ?? 0);
        $montoUnitario = (float) ($repuesto['montoUnitario'] ?? 0);
        $repuesto['cantidad'] = $cantidad;
        $repuesto['montoUnitario'] = $montoUnitario;
        $repuesto['total'] = $cantidad * $montoUnitario;
        $subtotal += $repuesto['total'];
    }
    unset($repuesto);
    $iva = 0;
    $monto = round($subtotal, 2);
    $repuestos = json_encode($listaRepuestos, JSON_UNESCAPED_UNICODE);

    if (!$ordenId || !$dictamen) {
        http_response_code(400);
        echo json_encode(['error' => 'orden_id y dictamen son requeridos']);
        return;
    }

    $pdo->beginTransaction();

    try {
        $stmt = $pdo->prepare('SELECT estado_actual FROM orden_servicio WHERE id = ? FOR UPDATE');
        $stmt->execute([$ordenId]);
        $orden = $stmt->fetch();

        if (!$orden || $orden['estado_actual'] !== 'en_diagnostico') {
            $pdo->rollBack();
            http_response_code(422);
            echo json_encode(['error' => 'La orden debe estar en diagnóstico para poder cotizar']);
            return;
        }

        // Comillas simples para 'pendiente' (ver nota en ordenes.php sobre ANSI_QUOTES)
        if ($abono > $monto) {
            $abono = $monto;
        }
        $stmtCotizacion = $pdo->prepare(
            "INSERT INTO cotizacion
                (orden_id, repuestos, dictamen, monto, subtotal, iva, abono, estado)
             VALUES (?, ?, ?, ?, ?, ?, ?, 'pendiente')"
        );
        $stmtCotizacion->execute([$ordenId, $repuestos, $dictamen, $monto, $subtotal, $iva, $abono]);
        $cotizacionId = $pdo->lastInsertId();

        $stmtDetalle = $pdo->prepare(
            'INSERT INTO cotizacion_detalle
                (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total)
             VALUES (?, ?, ?, ?, ?, ?, ?)'
        );
        foreach ($listaRepuestos as $indice => $repuesto) {
            $cantidad = (float) $repuesto['cantidad'];
            $precioUnitario = (float) $repuesto['montoUnitario'];
            $descripcion = trim((string) ($repuesto['descripcion'] ?? ''));
            $codigo = trim((string) ($repuesto['referencia'] ?? ''));
            $stmtDetalle->execute([
                $cotizacionId,
                $indice + 1,
                $codigo !== '' ? $codigo : null,
                $cantidad,
                $descripcion !== '' ? $descripcion : 'Repuesto o servicio',
                $precioUnitario,
                $cantidad * $precioUnitario,
            ]);
        }

        $estadoInicial = $abono > 0 ? 'esperando_abono' : 'cotizado';
        $pdo->prepare('UPDATE orden_servicio SET estado_actual = ? WHERE id = ?')
            ->execute([$estadoInicial, $ordenId]);

        $detalleRepuestos = array_map(
            static fn($r) => trim(($r['referencia'] ?? '') . " (x{$r['cantidad']}): $" . number_format((float) $r['total'], 0, ',', '.')),
            $listaRepuestos
        );
        $comentarioCotizacion = "Cotización: {$dictamen} - Total: $" . number_format((float) $monto, 0, ',', '.')
            . ($detalleRepuestos ? '. Repuestos: ' . implode(', ', $detalleRepuestos) : '');

        $pdo->prepare(
            "INSERT INTO historial_estado (orden_id, estado, comentario, usuario_id)
             VALUES (?, ?, ?, ?)"
        )->execute([$ordenId, $estadoInicial, $comentarioCotizacion, $usuarioAuth->sub]);

        $pdo->commit();

        http_response_code(201);
        echo json_encode([
            'orden_id' => $ordenId,
            'estado_nuevo' => $estadoInicial,
            'subtotal' => $subtotal,
            'iva' => $iva,
            'monto' => $monto,
        ]);
    } catch (\Exception $e) {
        $pdo->rollBack();
        error_log('Error al registrar cotizacion: ' . $e->getMessage());
        http_response_code(500);
        $mensaje = str_contains($e->getMessage(), "Unknown column 'abono'")
            ? 'La base de datos necesita ejecutar migration_v3.sql antes de registrar cotizaciones'
            : 'No se pudo registrar la cotización';
        echo json_encode(['error' => $mensaje]);
    }
}

function responderCotizacion(\PDO $pdo, object $usuarioAuth): void
{
    $datos = json_decode(file_get_contents('php://input'), true);

    $ordenId = $datos['orden_id'] ?? null;
    $respuesta = $datos['respuesta'] ?? null;
    $comentario = trim((string) ($datos['comentario'] ?? ''));
    $canal = 'whatsapp';

    if (!$ordenId || !$respuesta) {
        http_response_code(400);
        echo json_encode(['error' => 'orden_id y respuesta son requeridos']);
        return;
    }

    $pdo->beginTransaction();

    try {
        $stmt = $pdo->prepare(
            'SELECT id, estado_actual FROM orden_servicio WHERE id = ? FOR UPDATE'
        );
        $stmt->execute([$ordenId]);
        $orden = $stmt->fetch();

        if (!$orden) {
            $pdo->rollBack();
            http_response_code(404);
            echo json_encode(['error' => 'Orden no encontrada']);
            return;
        }

        if ($respuesta === 'en_espera') {
            $pdo->prepare("UPDATE orden_servicio SET estado_actual = 'esperando_respuesta' WHERE id = ?")
                ->execute([$ordenId]);
            $pdo->prepare(
                "INSERT INTO historial_estado (orden_id, estado, comentario, usuario_id)
                 VALUES (?, 'esperando_respuesta', 'Pendiente de respuesta del cliente', ?)"
            )->execute([$ordenId, $usuarioAuth->sub]);
            $pdo->commit();
            echo json_encode(['orden_id' => $ordenId, 'estado_nuevo' => 'esperando_respuesta'], JSON_UNESCAPED_UNICODE);
            return;
        }

        $estadoCotizacion = $respuesta === 'aprobada' ? 'aprobada' : 'rechazada';
        $stmtAbono = $pdo->prepare('SELECT abono FROM cotizacion WHERE orden_id = ? ORDER BY id DESC LIMIT 1');
        $stmtAbono->execute([$ordenId]);
        $abonoRequerido = (float) ($stmtAbono->fetchColumn() ?: 0);
        $nuevoEstadoOrden = $respuesta === 'aprobada'
            ? ($abonoRequerido > 0
                ? 'esperando_abono'
                : ($usuarioAuth->rol === 'recepcion' ? 'esperando_tecnico' : 'en_reparacion'))
            : 'no_autorizado';

        $pdo->prepare(
            'UPDATE cotizacion SET estado = ?, canal_aprobacion = ?, fecha_respuesta = NOW()
             WHERE orden_id = ? ORDER BY id DESC LIMIT 1'
        )->execute([$estadoCotizacion, $canal, $ordenId]);

        $pdo->prepare('UPDATE orden_servicio SET estado_actual = ? WHERE id = ?')
            ->execute([$nuevoEstadoOrden, $ordenId]);

        $pdo->prepare(
            "INSERT INTO historial_estado (orden_id, estado, comentario, usuario_id)
             VALUES (?, ?, ?, ?)"
        )->execute([$ordenId, $nuevoEstadoOrden, $comentario ?: "Cliente respondio: {$respuesta} (via {$canal})", $usuarioAuth->sub]);

        $pdo->commit();
        echo json_encode(['orden_id' => $ordenId, 'estado_nuevo' => $nuevoEstadoOrden]);
    } catch (\Exception $e) {
        $pdo->rollBack();
        http_response_code(500);
        echo json_encode(['error' => 'No se pudo registrar la respuesta']);
    }
}

// Permite agregar/editar repuestos de una cotización ya existente
// (por ejemplo cuando en plena reparación se necesita un repuesto adicional).
function editarRepuestos(\PDO $pdo, object $usuarioAuth): void
{
    $datos = json_decode(file_get_contents('php://input'), true);

    $ordenId = $datos['orden_id'] ?? null;
    $repuestos = $datos['repuestos'] ?? null;

    if (!$ordenId || $repuestos === null) {
        http_response_code(400);
        echo json_encode(['error' => 'orden_id y repuestos son requeridos']);
        return;
    }

    $listaRepuestos = json_decode($repuestos ?: '[]', true);
    if (!is_array($listaRepuestos)) {
        $listaRepuestos = [];
    }
    $subtotal = 0;
    foreach ($listaRepuestos as &$repuesto) {
        $cantidad = (int) ($repuesto['cantidad'] ?? 0);
        $montoUnitario = (float) ($repuesto['montoUnitario'] ?? 0);
        $repuesto['cantidad'] = $cantidad;
        $repuesto['montoUnitario'] = $montoUnitario;
        $repuesto['total'] = $cantidad * $montoUnitario;
        $subtotal += $repuesto['total'];
    }
    unset($repuesto);
    $monto = round($subtotal, 2);
    $repuestosJson = json_encode($listaRepuestos, JSON_UNESCAPED_UNICODE);

    $pdo->beginTransaction();

    try {
        $stmt = $pdo->prepare(
            'SELECT id, abono FROM cotizacion WHERE orden_id = ? ORDER BY id DESC LIMIT 1 FOR UPDATE'
        );
        $stmt->execute([$ordenId]);
        $cotizacion = $stmt->fetch();

        if (!$cotizacion) {
            $pdo->rollBack();
            http_response_code(404);
            echo json_encode(['error' => 'La orden no tiene una cotización registrada']);
            return;
        }

        $abono = min((float) $cotizacion['abono'], $monto);

        $pdo->prepare(
            'UPDATE cotizacion SET repuestos = ?, monto = ?, subtotal = ?, iva = 0, abono = ? WHERE id = ?'
        )->execute([$repuestosJson, $monto, $subtotal, $abono, $cotizacion['id']]);

        $pdo->prepare('DELETE FROM cotizacion_detalle WHERE cotizacion_id = ?')->execute([$cotizacion['id']]);
        $stmtDetalle = $pdo->prepare(
            'INSERT INTO cotizacion_detalle
                (cotizacion_id, item_n, codigo, cantidad, descripcion, precio_unitario, precio_total)
             VALUES (?, ?, ?, ?, ?, ?, ?)'
        );
        foreach ($listaRepuestos as $indice => $repuesto) {
            $cantidad = (float) $repuesto['cantidad'];
            $precioUnitario = (float) $repuesto['montoUnitario'];
            $descripcion = trim((string) ($repuesto['descripcion'] ?? ''));
            $codigo = trim((string) ($repuesto['referencia'] ?? ''));
            $stmtDetalle->execute([
                $cotizacion['id'],
                $indice + 1,
                $codigo !== '' ? $codigo : null,
                $cantidad,
                $descripcion !== '' ? $descripcion : 'Repuesto o servicio',
                $precioUnitario,
                $cantidad * $precioUnitario,
            ]);
        }

        $detalleRepuestos = array_map(
            static fn($r) => trim(($r['referencia'] ?? '') . " (x{$r['cantidad']}): $" . number_format((float) $r['total'], 0, ',', '.')),
            $listaRepuestos
        );
        $comentario = 'Repuestos actualizados. Nuevo total: $' . number_format($monto, 0, ',', '.')
            . ($detalleRepuestos ? '. Repuestos: ' . implode(', ', $detalleRepuestos) : '');

        $stmtOrden = $pdo->prepare('SELECT estado_actual FROM orden_servicio WHERE id = ?');
        $stmtOrden->execute([$ordenId]);
        $estadoActual = $stmtOrden->fetchColumn() ?: 'en_reparacion';

        $pdo->prepare(
            'INSERT INTO historial_estado (orden_id, estado, comentario, usuario_id)
             VALUES (?, ?, ?, ?)'
        )->execute([$ordenId, $estadoActual, $comentario, $usuarioAuth->sub]);

        $pdo->commit();
        echo json_encode(['orden_id' => $ordenId, 'monto' => $monto, 'subtotal' => $subtotal], JSON_UNESCAPED_UNICODE);
    } catch (\Exception $e) {
        $pdo->rollBack();
        error_log('Error al editar repuestos: ' . $e->getMessage());
        http_response_code(500);
        echo json_encode(['error' => 'No se pudo actualizar los repuestos']);
    }
}