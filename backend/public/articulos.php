<?php

require_once __DIR__ . '/../src/bootstrap.php';

use App\Database;
use App\Middleware;

header('Content-Type: application/json');

$usuarioAuth = Middleware::requireAuth(['recepcion', 'admin']);
$ferreteriaId = (int) $usuarioAuth->ferreteria_id;

$pdo = Database::getConnection();
$metodo = $_SERVER['REQUEST_METHOD'];

if ($metodo === 'POST') {
    $datos = json_decode(file_get_contents('php://input'), true) ?: [];
    if (($datos['operacion'] ?? '') === 'actualizar') {
        actualizarArticulo($pdo, $ferreteriaId, $datos);
    } else {
        crearArticulo($pdo, $ferreteriaId, $datos);
    }
} elseif ($metodo === 'GET') {
    listarArticulos($pdo, $ferreteriaId);
} elseif ($metodo === 'PATCH') {
    actualizarArticulo($pdo, $ferreteriaId);
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Método no permitido']);
}

function actualizarArticulo(\PDO $pdo, int $ferreteriaId, ?array $datos = null): void
{
    $datos ??= json_decode(file_get_contents('php://input'), true) ?: [];
    $articuloId = $datos['articulo_id'] ?? null;
    $tipo = trim((string) ($datos['tipo'] ?? ''));
    $marca = trim((string) ($datos['marca'] ?? ''));
    $modelo = trim((string) ($datos['modelo'] ?? ''));
    $serial = trim((string) ($datos['serial'] ?? ''));
    $accesorios = is_array($datos['accesorios'] ?? null) ? $datos['accesorios'] : [];

    if (!$articuloId || !$tipo) {
        http_response_code(400);
        echo json_encode(['error' => 'articulo_id y tipo son requeridos']);
        return;
    }

    $propietario = $pdo->prepare(
        'SELECT a.id FROM articulo a
         JOIN cliente c ON c.id = a.cliente_id
         WHERE a.id = ? AND c.ferreteria_id = ?'
    );
    $propietario->execute([$articuloId, $ferreteriaId]);
    if (!$propietario->fetchColumn()) {
        http_response_code(404);
        echo json_encode(['error' => 'Artículo no encontrado']);
        return;
    }

    $pdo->beginTransaction();
    try {
        $stmt = $pdo->prepare(
            'UPDATE articulo a
             JOIN cliente c ON c.id = a.cliente_id
             SET a.tipo = ?, a.marca = ?, a.modelo = ?, a.serial = ?
             WHERE a.id = ? AND c.ferreteria_id = ?'
        );
        $stmt->execute([$tipo, $marca ?: null, $modelo ?: null, $serial ?: null, $articuloId, $ferreteriaId]);

        $pdo->prepare('DELETE FROM accesorio WHERE articulo_id = ?')->execute([$articuloId]);
        $stmtAccesorio = $pdo->prepare('INSERT INTO accesorio (articulo_id, nombre, descripcion) VALUES (?, ?, ?)');
        foreach ($accesorios as $accesorio) {
            $nombre = trim((string) ($accesorio['nombre'] ?? ''));
            if ($nombre !== '') {
                $stmtAccesorio->execute([$articuloId, $nombre, trim((string) ($accesorio['descripcion'] ?? '')) ?: null]);
            }
        }
        $pdo->commit();
    } catch (\Exception $e) {
        $pdo->rollBack();
        http_response_code(500);
        echo json_encode(['error' => 'No se pudo actualizar el artículo']);
        return;
    }

    echo json_encode(['id' => $articuloId, 'tipo' => $tipo, 'marca' => $marca, 'modelo' => $modelo, 'serial' => $serial]);
}

function crearArticulo(\PDO $pdo, int $ferreteriaId, ?array $datos = null): void
{
    $datos ??= json_decode(file_get_contents('php://input'), true) ?: [];

    $clienteId = $datos['cliente_id'] ?? null;
    $tipo = $datos['tipo'] ?? null;
    $marca = $datos['marca'] ?? null;
    $modelo = $datos['modelo'] ?? null;
    $serial = $datos['serial'] ?? null;
    $accesorios = is_array($datos['accesorios'] ?? null) ? $datos['accesorios'] : [];

    if (!$clienteId || !$tipo) {
        http_response_code(400);
        echo json_encode(['error' => 'cliente_id y tipo son requeridos']);
        return;
    }

    $clienteStmt = $pdo->prepare('SELECT id FROM cliente WHERE id = ? AND ferreteria_id = ?');
    $clienteStmt->execute([$clienteId, $ferreteriaId]);
    if (!$clienteStmt->fetchColumn()) {
        http_response_code(404);
        echo json_encode(['error' => 'Cliente no encontrado']);
        return;
    }

    $pdo->beginTransaction();
    try {
        $stmt = $pdo->prepare(
            'INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (?, ?, ?, ?, ?)'
        );
        $stmt->execute([$clienteId, $tipo, $marca, $modelo, $serial]);
        $articuloId = $pdo->lastInsertId();
        $stmtAccesorio = $pdo->prepare('INSERT INTO accesorio (articulo_id, nombre, descripcion) VALUES (?, ?, ?)');
        foreach ($accesorios as $accesorio) {
            $nombre = trim((string) ($accesorio['nombre'] ?? ''));
            if ($nombre !== '') {
                $stmtAccesorio->execute([$articuloId, $nombre, trim((string) ($accesorio['descripcion'] ?? '')) ?: null]);
            }
        }
        $pdo->commit();
    } catch (\Exception $e) {
        $pdo->rollBack();
        http_response_code(500);
        echo json_encode(['error' => 'No se pudo crear el artículo']);
        return;
    }

    http_response_code(201);
    echo json_encode([
        'id' => $articuloId,
        'tipo' => $tipo,
        'marca' => $marca,
        'modelo' => $modelo,
    ]);
}

function listarArticulos(\PDO $pdo, int $ferreteriaId): void
{
    // Filtrado opcional por cliente: /articulos.php?cliente_id=1
    // Esto es lo que permite el "historial por cliente" que pidió tu amigo.
    $clienteId = $_GET['cliente_id'] ?? null;

    if ($clienteId) {
        $stmt = $pdo->prepare(
                "SELECT a.*, c.nombre AS cliente_nombre,
                    COALESCE((SELECT JSON_ARRAYAGG(JSON_OBJECT('id', ac.id, 'nombre', ac.nombre, 'descripcion', ac.descripcion)) FROM accesorio ac WHERE ac.articulo_id = a.id), JSON_ARRAY()) AS accesorios
             FROM articulo a
             JOIN cliente c ON c.id = a.cliente_id
             WHERE c.ferreteria_id = ? AND a.cliente_id = ?
             ORDER BY a.creado_en DESC"
        );
        $stmt->execute([$ferreteriaId, $clienteId]);
    } else {
        $stmt = $pdo->prepare(
                "SELECT a.*, c.nombre AS cliente_nombre,
                    COALESCE((SELECT JSON_ARRAYAGG(JSON_OBJECT('id', ac.id, 'nombre', ac.nombre, 'descripcion', ac.descripcion)) FROM accesorio ac WHERE ac.articulo_id = a.id), JSON_ARRAY()) AS accesorios
             FROM articulo a
             JOIN cliente c ON c.id = a.cliente_id
             WHERE c.ferreteria_id = ?
             ORDER BY a.creado_en DESC"
        );
        $stmt->execute([$ferreteriaId]);
    }

    echo json_encode($stmt->fetchAll());
}
