<?php

require_once __DIR__ . '/../src/bootstrap.php';

use App\Database;
use App\Middleware;

header('Content-Type: application/json; charset=utf-8');
$usuarioAuth = Middleware::requireAuth(['recepcion', 'admin', 'tecnico']);
$ferreteriaId = (int) $usuarioAuth->ferreteria_id;
$pdo = Database::getConnection();
$metodo = $_SERVER['REQUEST_METHOD'];

if ($metodo === 'GET') {
    $stmt = $pdo->prepare(
        'SELECT nombre_comercial, telefono, direccion, logo_key IS NOT NULL AS tiene_logo
         FROM ferreteria WHERE id = ?'
    );
    $stmt->execute([$ferreteriaId]);
    $marca = $stmt->fetch();

    if (!$marca) {
        http_response_code(404);
        echo json_encode(['error' => 'Ferretería no encontrada']);
        exit;
    }

    $marca['tiene_logo'] = (bool) $marca['tiene_logo'];
    echo json_encode($marca);
    exit;
}

if ($metodo === 'PUT') {
    if (!in_array($usuarioAuth->rol, ['recepcion', 'admin'], true)) {
        http_response_code(403);
        echo json_encode(['error' => 'No tienes permiso para modificar la marca de la ferretería']);
        exit;
    }

    $datos = json_decode(file_get_contents('php://input'), true);
    if (!is_array($datos)) {
        http_response_code(400);
        echo json_encode(['error' => 'El cuerpo de la petición no es válido']);
        exit;
    }

    $datosMarca = [
        'nombre_comercial' => $datos['nombre_comercial'] ?? '',
        'telefono' => $datos['telefono'] ?? '',
        'direccion' => $datos['direccion'] ?? '',
    ];
    foreach ($datosMarca as $campo => $valor) {
        if (!is_string($valor)) {
            http_response_code(400);
            echo json_encode(['error' => "El campo {$campo} debe ser texto"]);
            exit;
        }
    }

    $nombre = trim($datosMarca['nombre_comercial']);
    $telefono = trim($datosMarca['telefono']);
    $direccion = trim($datosMarca['direccion']);
    $longitudes = [
        'nombre_comercial' => [$nombre, 150],
        'telefono' => [$telefono, 60],
        'direccion' => [$direccion, 255],
    ];

    foreach ($longitudes as $campo => [$valor, $maximo]) {
        $coincidencias = [];
        if (preg_match_all('/./us', $valor, $coincidencias) === false || count($coincidencias[0]) > $maximo) {
            http_response_code(400);
            echo json_encode(['error' => "El campo {$campo} excede el tamaño permitido"]);
            exit;
        }
    }

    if ($nombre === '') {
        http_response_code(400);
        echo json_encode(['error' => 'El nombre comercial es obligatorio']);
        exit;
    }

    $stmt = $pdo->prepare(
        'UPDATE ferreteria
         SET nombre_comercial = ?, telefono = ?, direccion = ?
         WHERE id = ?'
    );
    $stmt->execute([
        $nombre,
        $telefono !== '' ? $telefono : null,
        $direccion !== '' ? $direccion : null,
        $ferreteriaId,
    ]);

    echo json_encode([
        'nombre_comercial' => $nombre,
        'telefono' => $telefono,
        'direccion' => $direccion,
    ]);
    exit;
}

http_response_code(405);
header('Allow: GET, PUT');
echo json_encode(['error' => 'Método no permitido']);
