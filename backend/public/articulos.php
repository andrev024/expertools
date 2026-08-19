<?php

require_once __DIR__ . '/../src/bootstrap.php';

use App\Database;
use App\Middleware;

header('Content-Type: application/json');

$usuarioAuth = Middleware::requireAuth(['recepcion', 'admin']);

$pdo = Database::getConnection();
$metodo = $_SERVER['REQUEST_METHOD'];

if ($metodo === 'POST') {
    crearArticulo($pdo);
} elseif ($metodo === 'GET') {
    listarArticulos($pdo);
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Método no permitido']);
}

function crearArticulo(\PDO $pdo): void
{
    $datos = json_decode(file_get_contents('php://input'), true);

    $clienteId = $datos['cliente_id'] ?? null;
    $tipo = $datos['tipo'] ?? null;
    $marca = $datos['marca'] ?? null;
    $modelo = $datos['modelo'] ?? null;
    $serial = $datos['serial'] ?? null;

    if (!$clienteId || !$tipo) {
        http_response_code(400);
        echo json_encode(['error' => 'cliente_id y tipo son requeridos']);
        return;
    }

    $stmt = $pdo->prepare(
        'INSERT INTO articulo (cliente_id, tipo, marca, modelo, serial) VALUES (?, ?, ?, ?, ?)'
    );
    $stmt->execute([$clienteId, $tipo, $marca, $modelo, $serial]);

    http_response_code(201);
    echo json_encode([
        'id' => $pdo->lastInsertId(),
        'tipo' => $tipo,
        'marca' => $marca,
        'modelo' => $modelo,
    ]);
}

function listarArticulos(\PDO $pdo): void
{
    // Filtrado opcional por cliente: /articulos.php?cliente_id=1
    // Esto es lo que permite el "historial por cliente" que pidió tu amigo.
    $clienteId = $_GET['cliente_id'] ?? null;

    if ($clienteId) {
        $stmt = $pdo->prepare(
            'SELECT a.*, c.nombre AS cliente_nombre
             FROM articulo a
             JOIN cliente c ON c.id = a.cliente_id
             WHERE a.cliente_id = ?
             ORDER BY a.creado_en DESC'
        );
        $stmt->execute([$clienteId]);
    } else {
        $stmt = $pdo->query(
            'SELECT a.*, c.nombre AS cliente_nombre
             FROM articulo a
             JOIN cliente c ON c.id = a.cliente_id
             ORDER BY a.creado_en DESC'
        );
    }

    echo json_encode($stmt->fetchAll());
}
