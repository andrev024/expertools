<?php

require_once __DIR__ . '/../src/bootstrap.php';

use App\Database;
use App\Middleware;

header('Content-Type: application/json');

$usuarioAuth = Middleware::requireAuth(['recepcion', 'admin']);

$pdo = Database::getConnection();
$metodo = $_SERVER['REQUEST_METHOD'];

if ($metodo === 'POST') {
    $datos = json_decode(file_get_contents('php://input'), true) ?: [];
    if (($datos['operacion'] ?? '') === 'actualizar' || !empty($datos['cliente_id'])) {
        actualizarCliente($pdo, $datos);
    } else {
        crearCliente($pdo, $datos);
    }
} elseif ($metodo === 'GET') {
    listarClientes($pdo);
} elseif ($metodo === 'PATCH') {
    actualizarCliente($pdo);
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Método no permitido']);
}

function actualizarCliente(\PDO $pdo, ?array $datos = null): void
{
    $datos ??= json_decode(file_get_contents('php://input'), true) ?: [];
    $clienteId = $datos['cliente_id'] ?? null;
    $nombre = trim((string) ($datos['nombre'] ?? ''));
    $empresa = trim((string) ($datos['empresa'] ?? ''));
    $correo = trim((string) ($datos['correo'] ?? ''));
    $telefono = trim((string) ($datos['telefono'] ?? ''));
    $telefono2 = trim((string) ($datos['telefono_2'] ?? ''));
    $direccion = trim((string) ($datos['direccion'] ?? ''));
    $cedula = trim((string) ($datos['cedula'] ?? ''));

    if (!$clienteId) {
        http_response_code(400);
        echo json_encode(['error' => 'cliente_id es requerido']);
        return;
    }

    $clienteStmt = $pdo->prepare('SELECT id FROM cliente WHERE id = ?');
    $clienteStmt->execute([$clienteId]);
    if (!$clienteStmt->fetchColumn()) {
        http_response_code(404);
        echo json_encode(['error' => 'Cliente no encontrado']);
        return;
    }

    $stmt = $pdo->prepare('UPDATE cliente SET nombre = ?, empresa = ?, correo = ?, telefono = ?, telefono_2 = ?, direccion = ?, cedula = ? WHERE id = ?');
    try {
        $stmt->execute([$nombre ?: null, $empresa ?: null, $correo ?: null, $telefono ?: null, $telefono2 ?: null, $direccion ?: null, $cedula ?: null, $clienteId]);
    } catch (\PDOException $e) {
        error_log('Error actualizando cliente ' . $clienteId . ': ' . $e->getMessage());
        http_response_code(500);
        echo json_encode(['error' => 'No se pudo guardar el cliente. Revisa que los datos sean válidos.']);
        return;
    }
    echo json_encode(['id' => $clienteId, 'nombre' => $nombre, 'empresa' => $empresa, 'correo' => $correo, 'telefono' => $telefono, 'telefono_2' => $telefono2, 'direccion' => $direccion, 'cedula' => $cedula]);
}

function crearCliente(\PDO $pdo, ?array $datos = null): void
{
    $datos ??= json_decode(file_get_contents('php://input'), true) ?: [];

    $nombre = $datos['nombre'] ?? null;
    $empresa = $datos['empresa'] ?? null;
    $correo = $datos['correo'] ?? null;
    $telefono = $datos['telefono'] ?? null;
    $telefono2 = $datos['telefono_2'] ?? null;
    $direccion = $datos['direccion'] ?? null;
    $cedula = $datos['cedula'] ?? null;

    if (!$nombre && !$empresa) {
        http_response_code(400);
        echo json_encode(['error' => 'nombre o empresa es requerido']);
        return;
    }

    $stmt = $pdo->prepare(
        'INSERT INTO cliente (nombre, empresa, correo, telefono, telefono_2, direccion, cedula) VALUES (?, ?, ?, ?, ?, ?, ?)'
    );
    $stmt->execute([$nombre, $empresa, $correo, $telefono, $telefono2, $direccion, $cedula]);

    http_response_code(201);
    echo json_encode([
        'id' => $pdo->lastInsertId(),
        'nombre' => $nombre,
        'empresa' => $empresa,
        'correo' => $correo,
        'telefono' => $telefono,
        'telefono_2' => $telefono2,
        'direccion' => $direccion,
    ]);
}

function listarClientes(\PDO $pdo): void
{
    // Busqueda opcional: /clientes.php?buscar=juan
    $buscar = $_GET['buscar'] ?? null;

    if ($buscar) {
        $stmt = $pdo->prepare(
            'SELECT * FROM cliente
             WHERE nombre LIKE ? OR empresa LIKE ? OR correo LIKE ? OR telefono LIKE ? OR cedula LIKE ?
             ORDER BY COALESCE(NULLIF(nombre, \'\'), empresa)'
        );
        $like = "%{$buscar}%";
        $stmt->execute([$like, $like, $like, $like, $like]);
    } else {
        $stmt = $pdo->query('SELECT * FROM cliente ORDER BY nombre');
    }

    echo json_encode($stmt->fetchAll());
}
