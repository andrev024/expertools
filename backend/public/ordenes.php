<?php

require_once __DIR__ . '/../src/bootstrap.php';

use App\Database;
use App\Middleware;
use App\GeneradorCodigo;

header('Content-Type: application/json; charset=utf-8');

$usuarioAuth = Middleware::requireAuth(['recepcion', 'tecnico', 'admin']);

$pdo = Database::getConnection();
$metodo = $_SERVER['REQUEST_METHOD'];

if ($metodo === 'POST') {
    if (!in_array($usuarioAuth->rol, ['recepcion', 'admin'])) {
        http_response_code(403);
        echo json_encode(['error' => 'Solo recepción puede crear órdenes']);
        exit;
    }
    crearOrden($pdo, $usuarioAuth);
} elseif ($metodo === 'PATCH') {
    actualizarUbicacion($pdo, $usuarioAuth);
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
    $tipo = $datos['tipo'] ?? 'reparacion';
    $ordenOriginalId = $datos['orden_original_id'] ?? null;
    $ubicacion = trim((string) ($datos['ubicacion'] ?? ''));

    if (!$articuloId) {
        http_response_code(400);
        echo json_encode(['error' => 'articulo_id es requerido']);
        return;
    }

    $codigoSeguimiento = GeneradorCodigo::generarCodigoSeguimiento();

    $pdo->beginTransaction();

    try {
        // NOTA: se usan comillas simples para el texto 'recibido', no dobles.
        // Con comillas dobles, algunos proveedores (como Aiven, que activa
        // ANSI_QUOTES) las interpretan como nombre de columna en vez de texto.
        $stmt = $pdo->prepare(
            "INSERT INTO orden_servicio
                     (codigo_seguimiento, articulo_id, tipo, orden_original_id, estado_actual, ubicacion_actual, fecha_ingreso)
                 VALUES (?, ?, ?, ?, 'recibido', ?, NOW())"
        );
          $stmt->execute([$codigoSeguimiento, $articuloId, $tipo, $ordenOriginalId, $ubicacion ?: null]);
        $ordenId = $pdo->lastInsertId();

        $stmtHistorial = $pdo->prepare(
            "INSERT INTO historial_estado (orden_id, estado, comentario, usuario_id)
             VALUES (?, 'recibido', ?, ?)"
        );
        $stmtAccesorios = $pdo->prepare(
            'SELECT GROUP_CONCAT(nombre SEPARATOR ", ")
             FROM accesorio
             WHERE articulo_id = ?'
        );
        $stmtAccesorios->execute([$articuloId]);
        $accesorios = trim((string) ($stmtAccesorios->fetchColumn() ?: ''));
        $comentarioRecepcion = $ubicacion
            ? "Articulo recibido en recepcion. Ubicacion: {$ubicacion}"
            : 'Articulo recibido en recepcion. Ubicacion pendiente';
        if ($accesorios !== '') {
            $comentarioRecepcion .= ". Accesorios: {$accesorios}";
        }
        $stmtHistorial->execute([$ordenId, $comentarioRecepcion, $usuarioAuth->sub]);

        $pdo->commit();

        http_response_code(201);
        echo json_encode([
            'id' => $ordenId,
            'codigo_seguimiento' => $codigoSeguimiento,
            'estado_actual' => 'recibido',
            'fecha_ingreso' => date('Y-m-d H:i:s'),
        ]);
    } catch (\Exception $e) {
        $pdo->rollBack();
        http_response_code(500);
        echo json_encode(['error' => 'No se pudo crear la orden']);
    }
}

function listarOrdenes(\PDO $pdo): void
{
    try {
        $stmt = $pdo->query(
                "SELECT os.id, os.codigo_seguimiento, os.tipo, os.estado_actual, os.fecha_ingreso,
                    COALESCE((SELECT MAX(h.fecha) FROM historial_estado h WHERE h.orden_id = os.id), os.fecha_ingreso) AS estado_desde,
                    a.tipo AS articulo_tipo, a.marca, a.modelo,
                    COALESCE((SELECT GROUP_CONCAT(ac.nombre SEPARATOR ', ') FROM accesorio ac WHERE ac.articulo_id = a.id), '') AS accesorios,
                    COALESCE(os.ubicacion_actual, (SELECT SUBSTRING_INDEX(h.comentario, 'Ubicacion: ', -1)
                              FROM historial_estado h
                              WHERE h.orden_id = os.id AND h.comentario LIKE '%Ubicacion:%'
                              ORDER BY h.fecha DESC LIMIT 1), '') AS ubicacion,
                    c.nombre AS cliente_nombre, c.telefono AS cliente_telefono
             FROM orden_servicio os
             JOIN articulo a ON a.id = os.articulo_id
             JOIN cliente c ON c.id = a.cliente_id
             ORDER BY os.fecha_ingreso ASC"
        );

        echo json_encode($stmt->fetchAll());
    } catch (\Exception $e) {
        error_log('Error al listar ordenes: ' . $e->getMessage());
        http_response_code(500);
        $mensaje = str_contains($e->getMessage(), "Unknown column 'os.ubicacion_actual'")
            ? 'Falta ejecutar migration_v4.sql en la base de datos'
            : (str_contains($e->getMessage(), "Table") && str_contains($e->getMessage(), 'accesorio')
                ? 'Falta ejecutar migration_v3.sql en la base de datos'
                : 'No se pudo obtener la lista de ordenes');
        echo json_encode(['error' => $mensaje]);
    }
}

function actualizarUbicacion(\PDO $pdo, object $usuarioAuth): void
{
    $datos = json_decode(file_get_contents('php://input'), true) ?: [];
    $ordenId = $datos['orden_id'] ?? null;
    $ubicacion = trim((string) ($datos['ubicacion'] ?? ''));

    if (!$ordenId || $ubicacion === '') {
        http_response_code(400);
        echo json_encode(['error' => 'orden_id y ubicación son requeridos']);
        return;
    }

    $stmt = $pdo->prepare('SELECT estado_actual FROM orden_servicio WHERE id = ?');
    $stmt->execute([$ordenId]);
    $orden = $stmt->fetch();
    if (!$orden) {
        http_response_code(404);
        echo json_encode(['error' => 'Orden no encontrada']);
        return;
    }

    $stmt = $pdo->prepare(
        'UPDATE orden_servicio SET ubicacion_actual = ? WHERE id = ?'
    );
    $stmt->execute([$ubicacion, $ordenId]);

    $stmt = $pdo->prepare(
        'INSERT INTO historial_estado (orden_id, estado, comentario, usuario_id)
         VALUES (?, ?, ?, ?)'
    );
    $stmt->execute([$ordenId, $orden['estado_actual'], "Ubicacion: {$ubicacion}", $usuarioAuth->sub]);
    echo json_encode(['orden_id' => $ordenId, 'ubicacion' => $ubicacion]);
}