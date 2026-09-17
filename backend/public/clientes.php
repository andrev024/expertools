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
} elseif ($metodo === 'DELETE') {
    eliminarCliente($pdo);
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Método no permitido']);
}

function eliminarCliente(\PDO $pdo): void
{
    $clienteId = $_GET['cliente_id'] ?? null;

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

    // Se borra en cascada TODO lo asociado al cliente: articulos, ordenes,
    // historial y cotizaciones. Esto es irreversible (lo advierte el frontend).
    $pdo->beginTransaction();
    try {
        $articulosStmt = $pdo->prepare('SELECT id FROM articulo WHERE cliente_id = ?');
        $articulosStmt->execute([$clienteId]);
        $articuloIds = $articulosStmt->fetchAll(\PDO::FETCH_COLUMN);

        if ($articuloIds) {
            $marcadoresArticulos = implode(',', array_fill(0, count($articuloIds), '?'));

            $ordenesStmt = $pdo->prepare("SELECT id FROM orden_servicio WHERE articulo_id IN ({$marcadoresArticulos})");
            $ordenesStmt->execute($articuloIds);
            $ordenIds = $ordenesStmt->fetchAll(\PDO::FETCH_COLUMN);

            if ($ordenIds) {
                $marcadoresOrdenes = implode(',', array_fill(0, count($ordenIds), '?'));

                // Ordenes de garantia que apuntan a una orden por borrar: se desvincula
                // en vez de bloquear el borrado por la FK auto-referenciada.
                $pdo->prepare("UPDATE orden_servicio SET orden_original_id = NULL WHERE orden_original_id IN ({$marcadoresOrdenes})")->execute($ordenIds);

                $cotizacionesStmt = $pdo->prepare("SELECT id FROM cotizacion WHERE orden_id IN ({$marcadoresOrdenes})");
                $cotizacionesStmt->execute($ordenIds);
                $cotizacionIds = $cotizacionesStmt->fetchAll(\PDO::FETCH_COLUMN);

                if ($cotizacionIds) {
                    $marcadoresCotizaciones = implode(',', array_fill(0, count($cotizacionIds), '?'));
                    $pdo->prepare("DELETE FROM cotizacion_detalle WHERE cotizacion_id IN ({$marcadoresCotizaciones})")->execute($cotizacionIds);
                }

                $pdo->prepare("DELETE FROM cotizacion WHERE orden_id IN ({$marcadoresOrdenes})")->execute($ordenIds);
                $pdo->prepare("DELETE FROM historial_estado WHERE orden_id IN ({$marcadoresOrdenes})")->execute($ordenIds);
                $pdo->prepare("DELETE FROM orden_servicio WHERE id IN ({$marcadoresOrdenes})")->execute($ordenIds);
            }

            $pdo->prepare("DELETE FROM accesorio WHERE articulo_id IN ({$marcadoresArticulos})")->execute($articuloIds);
            $pdo->prepare("DELETE FROM articulo WHERE id IN ({$marcadoresArticulos})")->execute($articuloIds);
        }

        $stmt = $pdo->prepare('DELETE FROM cliente WHERE id = ?');
        $stmt->execute([$clienteId]);
        $pdo->commit();
    } catch (\PDOException $e) {
        $pdo->rollBack();
        error_log('Error eliminando cliente ' . $clienteId . ': ' . $e->getMessage());
        http_response_code(409);
        echo json_encode(['error' => 'No se puede eliminar: el cliente tiene artículos u órdenes registradas.']);
        return;
    }

    echo json_encode(['id' => $clienteId, 'eliminado' => true]);
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

    $duplicado = buscarClienteDuplicado($pdo, $correo, $telefono, $telefono2, $clienteId);
    if ($duplicado) {
        http_response_code(409);
        echo json_encode(['error' => 'Ya existe otro cliente registrado con ese teléfono o correo.']);
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

    $duplicado = buscarClienteDuplicado($pdo, $correo, $telefono, $telefono2);
    if ($duplicado) {
        http_response_code(409);
        echo json_encode(['error' => 'Ya existe otro cliente registrado con ese teléfono o correo.']);
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

// Revisa si ya existe otro cliente con el mismo correo o telefono (en cualquiera de los 2 campos de telefono).
function buscarClienteDuplicado(\PDO $pdo, ?string $correo, ?string $telefono, ?string $telefono2, ?int $excluirClienteId = null): bool
{
    $correo = trim((string) $correo);
    $telefono = trim((string) $telefono);
    $telefono2 = trim((string) $telefono2);

    $condiciones = [];
    $parametros = [];

    if ($correo !== '') {
        $condiciones[] = 'correo = ?';
        $parametros[] = $correo;
    }
    foreach ([$telefono, $telefono2] as $tel) {
        if ($tel !== '') {
            $condiciones[] = 'telefono = ?';
            $parametros[] = $tel;
            $condiciones[] = 'telefono_2 = ?';
            $parametros[] = $tel;
        }
    }

    if (!$condiciones) {
        return false;
    }

    $sql = 'SELECT id FROM cliente WHERE (' . implode(' OR ', $condiciones) . ')';
    if ($excluirClienteId !== null) {
        $sql .= ' AND id != ?';
        $parametros[] = $excluirClienteId;
    }

    $stmt = $pdo->prepare($sql);
    $stmt->execute($parametros);

    return (bool) $stmt->fetchColumn();
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
