<?php

require_once __DIR__ . '/../src/bootstrap.php';

use App\Database;
use App\Middleware;

header('Content-Type: application/json');

$usuarioAuth = Middleware::requireAuth(['tecnico', 'admin']);

$pdo = Database::getConnection();
$metodo = $_SERVER['REQUEST_METHOD'];

if ($metodo === 'POST') {
    registrarCotizacion($pdo, $usuarioAuth);
} elseif ($metodo === 'PATCH') {
    responderCotizacion($pdo, $usuarioAuth);
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Método no permitido']);
}

function registrarCotizacion(\PDO $pdo, object $usuarioAuth): void
{
    $datos = json_decode(file_get_contents('php://input'), true);

    $ordenId = $datos['orden_id'] ?? null;
    $repuestos = $datos['repuestos'] ?? null;
    $dictamen = $datos['dictamen'] ?? null;
    $monto = $datos['monto'] ?? null;

    if (!$ordenId || !$dictamen || $monto === null) {
        http_response_code(400);
        echo json_encode(['error' => 'orden_id, dictamen y monto son requeridos']);
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
        $stmtCotizacion = $pdo->prepare(
            "INSERT INTO cotizacion (orden_id, repuestos, dictamen, monto, estado)
             VALUES (?, ?, ?, ?, 'pendiente')"
        );
        $stmtCotizacion->execute([$ordenId, $repuestos, $dictamen, $monto]);

        $pdo->prepare("UPDATE orden_servicio SET estado_actual = 'cotizado' WHERE id = ?")
            ->execute([$ordenId]);

        $pdo->prepare(
            "INSERT INTO historial_estado (orden_id, estado, comentario, usuario_id)
             VALUES (?, 'cotizado', ?, ?)"
        )->execute([$ordenId, "Cotización: {$dictamen} - $" . $monto, $usuarioAuth->sub]);

        $pdo->commit();

        http_response_code(201);
        echo json_encode(['orden_id' => $ordenId, 'estado_nuevo' => 'cotizado']);
    } catch (\Exception $e) {
        $pdo->rollBack();
        http_response_code(500);
        echo json_encode(['error' => 'No se pudo registrar la cotización']);
    }
}

function responderCotizacion(\PDO $pdo, object $usuarioAuth): void
{
    $datos = json_decode(file_get_contents('php://input'), true);

    $ordenId = $datos['orden_id'] ?? null;
    $respuesta = $datos['respuesta'] ?? null;
    $canal = 'whatsapp';

    if (!$ordenId || !$respuesta) {
        http_response_code(400);
        echo json_encode(['error' => 'orden_id y respuesta son requeridos']);
        return;
    }

    $pdo->beginTransaction();

    try {
        $stmt = $pdo->prepare(
            'SELECT id, intentos_contacto_cliente FROM orden_servicio WHERE id = ? FOR UPDATE'
        );
        $stmt->execute([$ordenId]);
        $orden = $stmt->fetch();

        if (!$orden) {
            $pdo->rollBack();
            http_response_code(404);
            echo json_encode(['error' => 'Orden no encontrada']);
            return;
        }

        if ($respuesta === 'intento_fallido') {
            $nuevosIntentos = $orden['intentos_contacto_cliente'] + 1;
            $pdo->prepare('UPDATE orden_servicio SET intentos_contacto_cliente = ? WHERE id = ?')
                ->execute([$nuevosIntentos, $ordenId]);

            if ($nuevosIntentos >= 3) {
                $pdo->prepare("UPDATE orden_servicio SET estado_actual = 'sin_respuesta' WHERE id = ?")
                    ->execute([$ordenId]);
                $pdo->prepare(
                    "INSERT INTO historial_estado (orden_id, estado, comentario, usuario_id)
                     VALUES (?, 'sin_respuesta', 'Cliente no respondio tras 3 intentos', ?)"
                )->execute([$ordenId, $usuarioAuth->sub]);
            } else {
                $pdo->prepare(
                    "INSERT INTO historial_estado (orden_id, estado, comentario, usuario_id)
                     VALUES (?, 'cotizado', ?, ?)"
                )->execute([$ordenId, "Intento de contacto #{$nuevosIntentos} sin respuesta", $usuarioAuth->sub]);
            }

            $pdo->commit();
            echo json_encode(['orden_id' => $ordenId, 'intentos' => $nuevosIntentos]);
            return;
        }

        $estadoCotizacion = $respuesta === 'aprobada' ? 'aprobada' : 'rechazada';
        $nuevoEstadoOrden = $respuesta === 'aprobada' ? 'en_reparacion' : 'no_autorizado';

        $pdo->prepare(
            'UPDATE cotizacion SET estado = ?, canal_aprobacion = ?, fecha_respuesta = NOW()
             WHERE orden_id = ? ORDER BY id DESC LIMIT 1'
        )->execute([$estadoCotizacion, $canal, $ordenId]);

        $pdo->prepare('UPDATE orden_servicio SET estado_actual = ? WHERE id = ?')
            ->execute([$nuevoEstadoOrden, $ordenId]);

        $pdo->prepare(
            'INSERT INTO historial_estado (orden_id, estado, comentario, usuario_id)
             VALUES (?, ?, ?, ?)'
        )->execute([$ordenId, $nuevoEstadoOrden, "Cliente respondio: {$respuesta} (via {$canal})", $usuarioAuth->sub]);

        $pdo->commit();
        echo json_encode(['orden_id' => $ordenId, 'estado_nuevo' => $nuevoEstadoOrden]);
    } catch (\Exception $e) {
        $pdo->rollBack();
        http_response_code(500);
        echo json_encode(['error' => 'No se pudo registrar la respuesta']);
    }
}