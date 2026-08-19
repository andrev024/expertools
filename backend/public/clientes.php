<?php

require_once __DIR__ . '/../src/bootstrap.php';

use App\Database;
use App\Middleware;

header('Content-Type: application/json');

$usuarioAuth = Middleware::requireAuth(['recepcion', 'admin']);

$pdo = Database::getConnection();
$metodo = $_SERVER['REQUEST_METHOD'];

if ($metodo === 'POST') {
    crearCliente($pdo);
} elseif ($metodo === 'GET') {
    listarClientes($pdo);
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Método no permitido']);
}

function crearCliente(\PDO $pdo): void
{
    $datos = json_decode(file_get_contents('php://input'), true);

    $nombre = $datos['nombre'] ?? null;
    $telefono = $datos['telefono'] ?? null;
    $cedula = $datos['cedula'] ?? null;

    if (!$nombre || !$telefono) {
        http_response_code(400);
        echo json_encode(['error' => 'nombre y telefono son requeridos']);
        return;
    }

    $stmt = $pdo->prepare('INSERT INTO cliente (nombre, telefono, cedula) VALUES (?, ?, ?)');
    $stmt->execute([$nombre, $telefono, $cedula]);

    http_response_code(201);
    echo json_encode([
        'id' => $pdo->lastInsertId(),
        'nombre' => $nombre,
        'telefono' => $telefono,
    ]);
}

function listarClientes(\PDO $pdo): void
{
    // Busqueda opcional: /clientes.php?buscar=juan
    $buscar = $_GET['buscar'] ?? null;

    if ($buscar) {
        $stmt = $pdo->prepare(
            'SELECT * FROM cliente WHERE nombre LIKE ? OR telefono LIKE ? ORDER BY nombre'
        );
        $like = "%{$buscar}%";
        $stmt->execute([$like, $like]);
    } else {
        $stmt = $pdo->query('SELECT * FROM cliente ORDER BY nombre');
    }

    echo json_encode($stmt->fetchAll());
}
