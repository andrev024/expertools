<?php

require_once __DIR__ . '/../src/bootstrap.php';


use App\Database;
use App\JwtHelper;

header('Content-Type: application/json');

$datos = json_decode(file_get_contents('php://input'), true);

$email = $datos['email'] ?? null;
$password = $datos['password'] ?? null;

if (!$email || !$password) {
    http_response_code(400);
    echo json_encode(['error' => 'Email y password son requeridos']);
    exit;
}

$pdo = Database::getConnection();

$stmt = $pdo->prepare(
    'SELECT u.id, u.ferreteria_id, f.slug AS ferreteria_slug,
            u.nombre, u.password_hash, u.rol
     FROM usuario u
     JOIN ferreteria f ON f.id = u.ferreteria_id
     WHERE u.email = ?'
);
$stmt->execute([$email]);
$usuario = $stmt->fetch();

// password_verify compara el texto plano contra el hash guardado.
// NUNCA se guarda ni se compara la contraseña en texto plano.
if (!$usuario || !password_verify($password, $usuario['password_hash'])) {
    http_response_code(401);
    echo json_encode(['error' => 'Credenciales inválidas']);
    exit;
}

$token = JwtHelper::generar(
    (int) $usuario['id'],
    (int) $usuario['ferreteria_id'],
    $usuario['rol']
);

echo json_encode([
    'token' => $token,
    'usuario' => [
        'id' => $usuario['id'],
        'ferreteria_id' => $usuario['ferreteria_id'],
        'ferreteria_slug' => $usuario['ferreteria_slug'],
        'nombre' => $usuario['nombre'],
        'rol' => $usuario['rol'],
    ],
]);
