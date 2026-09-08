<?php

require_once __DIR__ . '/../src/bootstrap.php';

use App\Database;
use App\Middleware;

header('Content-Type: application/json; charset=utf-8');
$usuarioAuth = Middleware::requireAuth(['recepcion', 'admin']);
$pdo = Database::getConnection();
$metodo = $_SERVER['REQUEST_METHOD'];

if ($metodo === 'GET') {
    echo json_encode($pdo->query('SELECT id, nombre, email, rol, creado_en FROM usuario ORDER BY nombre')->fetchAll());
    exit;
}

$datos = json_decode(file_get_contents('php://input'), true) ?: [];

if ($metodo === 'POST' || $metodo === 'PUT') {
    $id = $datos['id'] ?? null;
    $nombre = trim((string) ($datos['nombre'] ?? ''));
    $email = trim((string) ($datos['email'] ?? ''));
    $rol = $datos['rol'] ?? null;
    $password = (string) ($datos['password'] ?? '');
    if (!$nombre || !$email || !in_array($rol, ['recepcion', 'tecnico', 'admin'], true) || ($metodo === 'POST' && !$password)) {
        http_response_code(400);
        echo json_encode(['error' => 'Nombre, email, rol y contraseña son requeridos']);
        exit;
    }
    try {
        if ($metodo === 'POST') {
            $stmt = $pdo->prepare('INSERT INTO usuario (nombre, email, password_hash, rol) VALUES (?, ?, ?, ?)');
            $stmt->execute([$nombre, $email, password_hash($password, PASSWORD_DEFAULT), $rol]);
            $id = $pdo->lastInsertId();
        } else {
            if (!$id) {
                http_response_code(400);
                echo json_encode(['error' => 'id es requerido']);
                exit;
            }
            if ($password) {
                $stmt = $pdo->prepare('UPDATE usuario SET nombre = ?, email = ?, password_hash = ?, rol = ? WHERE id = ?');
                $stmt->execute([$nombre, $email, password_hash($password, PASSWORD_DEFAULT), $rol, $id]);
            } else {
                $stmt = $pdo->prepare('UPDATE usuario SET nombre = ?, email = ?, rol = ? WHERE id = ?');
                $stmt->execute([$nombre, $email, $rol, $id]);
            }
        }
        echo json_encode(['id' => $id, 'nombre' => $nombre, 'email' => $email, 'rol' => $rol]);
    } catch (\PDOException $e) {
        http_response_code(409);
        echo json_encode(['error' => 'El email ya está registrado o los datos no son válidos']);
    }
    exit;
}

if ($metodo === 'DELETE') {
    $id = $datos['id'] ?? ($_GET['id'] ?? null);
    if (!$id || (int) $id === (int) $usuarioAuth->sub) {
        http_response_code(400);
        echo json_encode(['error' => 'No puedes eliminar tu propio usuario']);
        exit;
    }
    $stmt = $pdo->prepare('DELETE FROM usuario WHERE id = ?');
    $stmt->execute([$id]);
    echo json_encode(['eliminado' => $stmt->rowCount() > 0]);
    exit;
}

http_response_code(405);
echo json_encode(['error' => 'Método no permitido']);
