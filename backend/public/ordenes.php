<?php

require_once __DIR__ . '/../src/bootstrap.php';

use App\Database;
use App\Middleware;
use App\GeneradorCodigo;

header('Content-Type: application/json; charset=utf-8');

$usuarioAuth = Middleware::requireAuth(['recepcion', 'tecnico', 'admin']);
$ferreteriaId = (int) $usuarioAuth->ferreteria_id;

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
    if (($_GET['modo'] ?? '') === 'lista') {
        listarOrdenesPaginadas($pdo, $usuarioAuth);
    } elseif (isset($_GET['detalle_id'])) {
        obtenerOrdenPorId($pdo, $ferreteriaId, (int) $_GET['detalle_id']);
    } else {
        listarOrdenes($pdo, $ferreteriaId);
    }
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
    $cliente = is_array($datos['cliente'] ?? null) ? $datos['cliente'] : null;
    $articulo = is_array($datos['articulo'] ?? null) ? $datos['articulo'] : null;

    if (!$articuloId) {
        http_response_code(400);
        echo json_encode(['error' => 'articulo_id es requerido']);
        return;
    }

    $stmtPropiedad = $pdo->prepare(
        'SELECT c.id AS cliente_id
         FROM articulo a
         JOIN cliente c ON c.id = a.cliente_id
         WHERE a.id = ? AND c.ferreteria_id = ?'
    );
    $stmtPropiedad->execute([$articuloId, (int) $usuarioAuth->ferreteria_id]);
    $propiedadArticulo = $stmtPropiedad->fetch();
    if (!$propiedadArticulo) {
        http_response_code(404);
        echo json_encode(['error' => 'Artículo no encontrado']);
        return;
    }

    if ($cliente && !empty($cliente['id']) && (int) $cliente['id'] !== (int) $propiedadArticulo['cliente_id']) {
        http_response_code(400);
        echo json_encode(['error' => 'El cliente no corresponde al artículo']);
        return;
    }

    if ($articulo && !empty($articulo['id']) && (int) $articulo['id'] !== (int) $articuloId) {
        http_response_code(400);
        echo json_encode(['error' => 'El artículo no corresponde a la orden']);
        return;
    }

    if ($ordenOriginalId) {
        $stmtOrdenOriginal = $pdo->prepare(
            'SELECT os.id
             FROM orden_servicio os
             JOIN articulo a ON a.id = os.articulo_id
             JOIN cliente c ON c.id = a.cliente_id
             WHERE os.id = ? AND c.ferreteria_id = ?'
        );
        $stmtOrdenOriginal->execute([$ordenOriginalId, (int) $usuarioAuth->ferreteria_id]);
        if (!$stmtOrdenOriginal->fetchColumn()) {
            http_response_code(404);
            echo json_encode(['error' => 'Orden original no encontrada']);
            return;
        }
    }

    $pdo->beginTransaction();

    try {
        $ferreteriaId = (int) $usuarioAuth->ferreteria_id;
        $codigoSeguimiento = GeneradorCodigo::generarCodigoSeguimiento($pdo, $ferreteriaId);

        if ($cliente && !empty($cliente['id'])) {
            $stmtCliente = $pdo->prepare(
                'UPDATE cliente SET nombre = ?, empresa = ?, correo = ?, telefono = ?, telefono_2 = ?, direccion = ?, cedula = ? WHERE id = ? AND ferreteria_id = ?'
            );
            $stmtCliente->execute([
                trim((string) ($cliente['nombre'] ?? '')) ?: null,
                trim((string) ($cliente['empresa'] ?? '')) ?: null,
                trim((string) ($cliente['correo'] ?? '')) ?: null,
                trim((string) ($cliente['telefono'] ?? '')) ?: null,
                trim((string) ($cliente['telefono_2'] ?? '')) ?: null,
                trim((string) ($cliente['direccion'] ?? '')) ?: null,
                trim((string) ($cliente['cedula'] ?? '')) ?: null,
                $cliente['id'],
                (int) $usuarioAuth->ferreteria_id,
            ]);
        }

        if ($articulo && !empty($articulo['id'])) {
            $stmtArticulo = $pdo->prepare(
                'UPDATE articulo
                 SET tipo = ?, marca = ?, modelo = ?, serial = ?
                 WHERE id = ?
                   AND cliente_id IN (
                       SELECT id FROM cliente WHERE ferreteria_id = ?
                   )'
            );
            $stmtArticulo->execute([
                trim((string) ($articulo['tipo'] ?? '')),
                trim((string) ($articulo['marca'] ?? '')) ?: null,
                trim((string) ($articulo['modelo'] ?? '')) ?: null,
                trim((string) ($articulo['serial'] ?? '')) ?: null,
                $articulo['id'],
                (int) $usuarioAuth->ferreteria_id,
            ]);
            $pdo->prepare('DELETE FROM accesorio WHERE articulo_id = ?')->execute([$articulo['id']]);
            $stmtAccesorio = $pdo->prepare('INSERT INTO accesorio (articulo_id, nombre, descripcion) VALUES (?, ?, ?)');
            foreach (($articulo['accesorios'] ?? []) as $accesorio) {
                $nombre = trim((string) ($accesorio['nombre'] ?? ''));
                if ($nombre !== '') {
                    $stmtAccesorio->execute([$articulo['id'], $nombre, trim((string) ($accesorio['descripcion'] ?? '')) ?: null]);
                }
            }
        }

        // NOTA: se usan comillas simples para el texto 'recibido', no dobles.
        // Con comillas dobles, algunos proveedores (como Aiven, que activa
        // ANSI_QUOTES) las interpretan como nombre de columna en vez de texto.
        $stmt = $pdo->prepare(
            "INSERT INTO orden_servicio
                     (ferreteria_id, codigo_seguimiento, articulo_id, tipo, orden_original_id, estado_actual, ubicacion_actual, fecha_ingreso)
                 VALUES (?, ?, ?, ?, ?, 'recibido', ?, NOW())"
        );
        $stmt->execute([$ferreteriaId, $codigoSeguimiento, $articuloId, $tipo, $ordenOriginalId, $ubicacion ?: null]);
        $ordenId = Database::getLastInsertId($pdo, 'orden_servicio');

        $stmtHistorial = $pdo->prepare(
            "INSERT INTO historial_estado (orden_id, estado, comentario, usuario_id)
             VALUES (?, 'recibido', ?, ?)"
        );
        $agregadorNombres = $pdo->getAttribute(\PDO::ATTR_DRIVER_NAME) === 'pgsql'
            ? "STRING_AGG(nombre, ', ')"
            : "GROUP_CONCAT(nombre SEPARATOR ', ')";
        $stmtAccesorios = $pdo->prepare(
            "SELECT {$agregadorNombres}
             FROM accesorio
             WHERE articulo_id = ?"
        );
        $stmtAccesorios->execute([$articuloId]);
        $accesorios = trim((string) ($stmtAccesorios->fetchColumn() ?: ''));
        $comentarioRecepcion = 'Articulo recibido en recepcion';
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

function listarOrdenes(\PDO $pdo, int $ferreteriaId): void
{
    try {
        $agregadorJson = $pdo->getAttribute(\PDO::ATTR_DRIVER_NAME) === 'pgsql'
            ? "COALESCE((SELECT JSON_AGG(JSON_BUILD_OBJECT('nombre', ac.nombre, 'descripcion', ac.descripcion)) FROM accesorio ac WHERE ac.articulo_id = a.id), '[]'::json)"
            : "COALESCE((SELECT JSON_ARRAYAGG(JSON_OBJECT('nombre', ac.nombre, 'descripcion', ac.descripcion)) FROM accesorio ac WHERE ac.articulo_id = a.id), JSON_ARRAY())";
        $extraerUbicacion = $pdo->getAttribute(\PDO::ATTR_DRIVER_NAME) === 'pgsql'
            ? "REGEXP_REPLACE(h.comentario, '(?s)^.*Ubicacion: ', '')"
            : "SUBSTRING_INDEX(h.comentario, 'Ubicacion: ', -1)";

        $stmt = $pdo->prepare(
                "SELECT os.id, os.codigo_seguimiento, os.tipo, os.estado_actual, os.fecha_ingreso,
                    COALESCE((SELECT MAX(h.fecha) FROM historial_estado h WHERE h.orden_id = os.id), os.fecha_ingreso) AS estado_desde,
                    a.tipo AS articulo_tipo, a.marca, a.modelo,
                    {$agregadorJson} AS accesorios,
                    COALESCE(os.ubicacion_actual, (SELECT {$extraerUbicacion}
                              FROM historial_estado h
                              WHERE h.orden_id = os.id AND h.comentario LIKE '%Ubicacion:%'
                              ORDER BY h.fecha DESC LIMIT 1), '') AS ubicacion,
                    c.nombre AS cliente_nombre, c.empresa AS cliente_empresa, c.telefono AS cliente_telefono, c.telefono_2 AS cliente_telefono_2,
                    c.correo AS cliente_correo, c.cedula AS cliente_cedula
             FROM orden_servicio os
             JOIN articulo a ON a.id = os.articulo_id
             JOIN cliente c ON c.id = a.cliente_id
             WHERE c.ferreteria_id = ?
             ORDER BY os.fecha_ingreso ASC"
        );
        $stmt->execute([$ferreteriaId]);

        $ordenes = $stmt->fetchAll();
        foreach ($ordenes as &$orden) {
            $orden['accesorios'] = json_decode($orden['accesorios'] ?: '[]', true) ?: [];
        }
        unset($orden);
        echo json_encode($ordenes);
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

function obtenerOrdenPorId(\PDO $pdo, int $ferreteriaId, int $ordenId): void
{
    if ($ordenId < 1) {
        http_response_code(400);
        echo json_encode(['error' => 'detalle_id no es válido']);
        return;
    }

    try {
        $lista = consultarOrdenesPaginadas($pdo, $ferreteriaId, 'recepcion', 'todas', 1, 1, $ordenId);
        $orden = $lista['ordenes'][0] ?? null;
        if (!$orden) {
            http_response_code(404);
            echo json_encode(['error' => 'Orden no encontrada']);
            return;
        }
        echo json_encode($orden, JSON_UNESCAPED_UNICODE);
    } catch (\Throwable $e) {
        error_log('Error al consultar orden por id: ' . $e->getMessage());
        http_response_code(500);
        echo json_encode(['error' => 'No se pudo obtener la orden']);
    }
}

function listarOrdenesPaginadas(\PDO $pdo, object $usuarioAuth): void
{
    $vista = (string) ($_GET['vista'] ?? '');
    if (!in_array($vista, ['recepcion', 'tecnico'], true)) {
        http_response_code(400);
        echo json_encode(['error' => 'La vista solicitada no es válida']);
        return;
    }
    if ($vista === 'tecnico' && $usuarioAuth->rol !== 'tecnico') {
        http_response_code(403);
        echo json_encode(['error' => 'No tienes permiso para consultar esta vista']);
        return;
    }
    if ($vista !== 'tecnico' && !in_array($usuarioAuth->rol, ['recepcion', 'admin'], true)) {
        http_response_code(403);
        echo json_encode(['error' => 'No tienes permiso para consultar esta vista']);
        return;
    }

    try {
        $pagina = filter_var($_GET['pagina'] ?? 1, FILTER_VALIDATE_INT);
        if ($pagina === false || $pagina < 1 || $pagina > 100000) {
            throw new InvalidArgumentException('El número de página no es válido.');
        }
        $porPagina = filter_var($_GET['por_pagina'] ?? 10, FILTER_VALIDATE_INT);
        if (!in_array($porPagina, [10, 15, 25], true)) {
            throw new InvalidArgumentException('El tamaño de página debe ser 10, 15 o 25.');
        }
        $seccion = (string) ($_GET['seccion'] ?? 'todas');
        if (!in_array($seccion, ['todas', 'cotizaciones', 'acciones'], true)) {
            throw new InvalidArgumentException('La sección solicitada no es válida.');
        }
        if ($vista === 'tecnico' && $seccion !== 'todas') {
            throw new InvalidArgumentException('La sección técnica solicitada no es válida.');
        }
        $filtroEstado = (string) ($_GET['estado'] ?? 'todos');
        $filtroAntiguedad = (string) ($_GET['antiguedad'] ?? 'todas');
        $filtroTipo = (string) ($_GET['tipo'] ?? 'todos');
        $filtroUbicacion = (string) ($_GET['ubicacion'] ?? 'todas');
        $filtroResumen = (string) ($_GET['resumen'] ?? 'todas');
        $busqueda = trim((string) ($_GET['buscar'] ?? ''));
        if (strlen($busqueda) > 480) {
            throw new InvalidArgumentException('La búsqueda no puede superar 120 caracteres.');
        }
        if (!in_array($filtroAntiguedad, ['todas', 'una_semana', 'dos_tres_semanas', 'cuatro_semanas'], true)) {
            throw new InvalidArgumentException('El filtro de antigüedad no es válido.');
        }
        if (!in_array($filtroTipo, ['todos', 'reparacion', 'garantia', 'mantenimiento'], true)) {
            throw new InvalidArgumentException('El filtro de tipo no es válido.');
        }
        if (strlen($filtroUbicacion) > 600) {
            throw new InvalidArgumentException('La ubicación no es válida.');
        }
        if (!in_array($filtroResumen, ['todas', 'pendientes', 'estancadas', 'esperando_abono'], true)) {
            throw new InvalidArgumentException('El resumen solicitado no es válido.');
        }
        $ordenCodigo = (string) ($_GET['orden'] ?? 'asc');
        if (!in_array($ordenCodigo, ['asc', 'desc'], true)) {
            throw new InvalidArgumentException('El orden solicitado no es válido.');
        }

        $datos = consultarOrdenesPaginadas(
            $pdo,
            (int) $usuarioAuth->ferreteria_id,
            $vista,
            $seccion,
            $pagina,
            $porPagina,
            null,
            $filtroEstado,
            $filtroAntiguedad,
            $filtroTipo,
            $filtroUbicacion,
            $filtroResumen,
            $busqueda,
            $ordenCodigo
        );
        echo json_encode($datos, JSON_UNESCAPED_UNICODE);
    } catch (InvalidArgumentException $e) {
        http_response_code(400);
        echo json_encode(['error' => $e->getMessage()]);
    } catch (\Throwable $e) {
        error_log('Error al consultar página de órdenes: ' . $e->getMessage());
        http_response_code(500);
        echo json_encode(['error' => 'No se pudo obtener la página de órdenes']);
    }
}

function consultarOrdenesPaginadas(
    \PDO $pdo,
    int $ferreteriaId,
    string $vista,
    string $seccion,
    int $pagina,
    int $porPagina,
    ?int $detalleId = null,
    string $filtroEstado = 'todos',
    string $filtroAntiguedad = 'todas',
    string $filtroTipo = 'todos',
    string $filtroUbicacion = 'todas',
    string $filtroResumen = 'todas',
    string $busqueda = '',
    string $ordenCodigo = 'asc'
): array {
    $estadosTecnico = [
        'recibido', 'sin_respuesta', 'en_diagnostico', 'cotizado', 'esperando_respuesta',
        'esperando_abono', 'esperando_tecnico', 'en_reparacion', 'esperando_repuesto',
        'finalizado_tecnico',
    ];
    $gruposTecnico = [
        'recibido' => ['recibido', 'sin_respuesta'],
        'cotizado' => ['cotizado'],
        'esperando_respuesta' => ['esperando_respuesta'],
        'esperando_abono' => ['esperando_abono'],
        'en_reparacion' => ['en_diagnostico', 'esperando_tecnico', 'en_reparacion', 'esperando_repuesto', 'finalizado_tecnico'],
    ];
    $estadoNormalizadoSql = "CASE
        WHEN UPPER(os.estado_actual) LIKE '%ENTREGAD%' THEN 'entregado'
        WHEN UPPER(os.estado_actual) LIKE '%CHATARRA%' THEN 'chatarra'
        WHEN UPPER(os.estado_actual) ~ 'NO.?AUTORIZAD|NO.?JUSTIFIC' THEN 'no_autorizado'
        WHEN UPPER(os.estado_actual) LIKE '%COT%' THEN 'cotizado'
        WHEN UPPER(os.estado_actual) LIKE '%INGRESO%' THEN 'recibido'
        WHEN os.estado_actual IN (
            'recibido', 'en_diagnostico', 'cotizado', 'esperando_abono',
            'esperando_tecnico', 'esperando_respuesta', 'en_reparacion',
            'esperando_repuesto', 'finalizado_tecnico', 'en_revision_recepcion',
            'listo_para_entregar', 'entregado', 'chatarra', 'no_autorizado'
        ) THEN os.estado_actual
        ELSE 'historico'
    END";
    $estadoConteoSql = $vista === 'tecnico' ? 'os.estado_actual' : $estadoNormalizadoSql;
    $estadosCotizaciones = ['cotizado', 'esperando_respuesta'];
    $estadosAcciones = ['esperando_abono', 'en_revision_recepcion', 'listo_para_entregar'];

    $baseFrom = '
        FROM orden_servicio os
        JOIN articulo a ON a.id = os.articulo_id
        JOIN cliente c ON c.id = a.cliente_id
        LEFT JOIN LATERAL (
            SELECT MAX(h.fecha) AS fecha
            FROM historial_estado h
            WHERE h.orden_id = os.id
        ) h_estado ON TRUE
        LEFT JOIN LATERAL (
            SELECT REGEXP_REPLACE(h.comentario, \'(?s)^.*Ubicacion: \', \'\') AS ubicacion
            FROM historial_estado h
            WHERE h.orden_id = os.id AND h.comentario LIKE \'%Ubicacion:%\'
            ORDER BY h.fecha DESC, h.id DESC
            LIMIT 1
        ) h_ubicacion ON TRUE';

    $baseWhere = ['c.ferreteria_id = ?'];
    $baseParams = [$ferreteriaId];
    if ($vista === 'tecnico') {
        $baseWhere[] = 'os.estado_actual IN (' . implode(', ', array_fill(0, count($estadosTecnico), '?')) . ')';
        array_push($baseParams, ...$estadosTecnico);
    } elseif ($seccion === 'cotizaciones') {
        $baseWhere[] = 'os.estado_actual IN (?, ?)';
        array_push($baseParams, ...$estadosCotizaciones);
    } elseif ($seccion === 'acciones') {
        $baseWhere[] = 'os.estado_actual IN (?, ?, ?)';
        array_push($baseParams, ...$estadosAcciones);
    }
    if ($detalleId !== null) {
        $baseWhere[] = 'os.id = ?';
        $baseParams[] = $detalleId;
    }

    $filtros = [];
    $filtroParams = [];
    if ($busqueda !== '') {
        $filtros[] = '(os.codigo_seguimiento ILIKE ? OR c.nombre ILIKE ? OR c.empresa ILIKE ? OR a.tipo ILIKE ? OR a.marca ILIKE ? OR a.modelo ILIKE ? OR c.telefono ILIKE ? OR c.telefono_2 ILIKE ? OR c.correo ILIKE ? OR c.cedula ILIKE ?)';
        $coincidencia = '%' . $busqueda . '%';
        array_push($filtroParams, ...array_fill(0, 10, $coincidencia));
    }
    if ($filtroAntiguedad === 'una_semana') {
        $filtros[] = 'os.fecha_ingreso <= NOW() - INTERVAL \'7 days\'';
    } elseif ($filtroAntiguedad === 'dos_tres_semanas') {
        $filtros[] = 'os.fecha_ingreso <= NOW() - INTERVAL \'14 days\' AND os.fecha_ingreso > NOW() - INTERVAL \'28 days\'';
    } elseif ($filtroAntiguedad === 'cuatro_semanas') {
        $filtros[] = 'os.fecha_ingreso <= NOW() - INTERVAL \'28 days\'';
    }
    if ($filtroTipo !== 'todos') {
        $filtros[] = 'os.tipo = ?';
        $filtroParams[] = $filtroTipo;
    }
    if ($filtroUbicacion !== 'todas') {
        $filtros[] = 'COALESCE(os.ubicacion_actual, h_ubicacion.ubicacion, \'\') = ?';
        $filtroParams[] = $filtroUbicacion;
    }
    if ($filtroResumen === 'esperando_abono') {
        $filtros[] = 'os.estado_actual = ?';
        $filtroParams[] = 'esperando_abono';
    } elseif ($filtroResumen === 'pendientes') {
        $filtros[] = "UPPER(os.estado_actual) !~ 'ENTREGAD|CHATARRA|CANCELAD|NO.?AUTORIZAD'";
        $filtros[] = 'COALESCE(h_estado.fecha, os.fecha_ingreso) > NOW() - INTERVAL \'29 days\'';
    } elseif ($filtroResumen === 'estancadas') {
        $filtros[] = "UPPER(os.estado_actual) !~ 'ENTREGAD|CHATARRA|CANCELAD|NO.?AUTORIZAD'";
        $filtros[] = 'COALESCE(h_estado.fecha, os.fecha_ingreso) <= NOW() - INTERVAL \'29 days\'';
    }

    $where = array_merge($baseWhere, $filtros);
    $params = array_merge($baseParams, $filtroParams);
    if ($filtroEstado !== 'todos') {
        if ($vista === 'tecnico' && isset($gruposTecnico[$filtroEstado])) {
            $estados = $gruposTecnico[$filtroEstado];
            $where[] = 'os.estado_actual IN (' . implode(', ', array_fill(0, count($estados), '?')) . ')';
            array_push($params, ...$estados);
        } elseif ($vista !== 'tecnico' && preg_match('/^[a-z_]{1,50}$/', $filtroEstado)) {
            $where[] = '(' . $estadoNormalizadoSql . ') = ?';
            $params[] = $filtroEstado;
        } else {
            throw new InvalidArgumentException('El filtro de estado no es válido.');
        }
    }

    $whereSql = ' WHERE ' . implode(' AND ', $where);
    $conteoStmt = $pdo->prepare('SELECT COUNT(*) ' . $baseFrom . $whereSql);
    $conteoStmt->execute($params);
    $total = (int) $conteoStmt->fetchColumn();
    $totalPaginas = max(1, (int) ceil($total / $porPagina));
    $pagina = min($pagina, $totalPaginas);

    $orden = $vista === 'tecnico'
        ? 'os.fecha_ingreso ASC, os.id ASC'
        : ($ordenCodigo === 'desc'
            ? "NULLIF(REGEXP_REPLACE(os.codigo_seguimiento, '[^0-9]', '', 'g'), '')::numeric DESC NULLS LAST, os.codigo_seguimiento DESC, os.id DESC"
            : "NULLIF(REGEXP_REPLACE(os.codigo_seguimiento, '[^0-9]', '', 'g'), '')::numeric ASC NULLS LAST, os.codigo_seguimiento ASC, os.id ASC");
    $offset = ($pagina - 1) * $porPagina;
    $sqlOrdenes = '
        SELECT os.id, os.codigo_seguimiento, os.tipo, os.estado_actual, os.fecha_ingreso,
               COALESCE(h_estado.fecha, os.fecha_ingreso) AS estado_desde,
               a.tipo AS articulo_tipo, a.marca, a.modelo,
               COALESCE(
                   (SELECT JSON_AGG(JSON_BUILD_OBJECT(\'nombre\', ac.nombre, \'descripcion\', ac.descripcion))
                    FROM accesorio ac WHERE ac.articulo_id = a.id),
                   \'[]\'::json
               ) AS accesorios,
               COALESCE(os.ubicacion_actual, h_ubicacion.ubicacion, \'\') AS ubicacion,
               c.nombre AS cliente_nombre, c.empresa AS cliente_empresa,
               c.telefono AS cliente_telefono, c.telefono_2 AS cliente_telefono_2,
               c.correo AS cliente_correo, c.cedula AS cliente_cedula
        ' . $baseFrom . $whereSql . "
        ORDER BY {$orden}
        LIMIT ? OFFSET ?";
    $stmt = $pdo->prepare($sqlOrdenes);
    $stmt->execute(array_merge($params, [$porPagina, $offset]));
    $ordenes = $stmt->fetchAll();
    foreach ($ordenes as &$ordenFila) {
        if (is_string($ordenFila['accesorios'])) {
            $ordenFila['accesorios'] = json_decode($ordenFila['accesorios'], true) ?: [];
        }
    }
    unset($ordenFila);
    if ($detalleId !== null) {
        return ['ordenes' => $ordenes];
    }

    $whereSinEstado = array_merge($baseWhere, $filtros);
    $paramsSinEstado = array_merge($baseParams, $filtroParams);
    $conteosEstadoStmt = $pdo->prepare(
        'SELECT ' . $estadoConteoSql . ', COUNT(*)
         ' . $baseFrom . ' WHERE ' . implode(' AND ', $whereSinEstado) . '
         GROUP BY 1'
    );
    $conteosEstadoStmt->execute($paramsSinEstado);
    $conteosEstados = [];
    foreach ($conteosEstadoStmt->fetchAll(PDO::FETCH_KEY_PAIR) as $estado => $cantidad) {
        $conteosEstados[$estado] = (int) $cantidad;
    }

    $resumen = [];
    $secciones = [];
    $tipos = [];
    $ubicaciones = [];
    if ($vista !== 'tecnico') {
        $resumenStmt = $pdo->prepare(
            "SELECT COUNT(*) AS todas,
                    COUNT(*) FILTER (
                        WHERE UPPER(os.estado_actual) !~ 'ENTREGAD|CHATARRA|CANCELAD|NO.?AUTORIZAD'
                          AND COALESCE(h_estado.fecha, os.fecha_ingreso) > NOW() - INTERVAL '29 days'
                    ) AS pendientes,
                    COUNT(*) FILTER (
                        WHERE UPPER(os.estado_actual) !~ 'ENTREGAD|CHATARRA|CANCELAD|NO.?AUTORIZAD'
                          AND COALESCE(h_estado.fecha, os.fecha_ingreso) <= NOW() - INTERVAL '29 days'
                    ) AS estancadas,
                    COUNT(*) FILTER (WHERE os.estado_actual = 'esperando_abono') AS esperando_abono
             {$baseFrom}
             WHERE c.ferreteria_id = ?"
        );
        $resumenStmt->execute([$ferreteriaId]);
        $resumen = array_map('intval', $resumenStmt->fetch(PDO::FETCH_ASSOC) ?: []);

        $seccionesStmt = $pdo->prepare(
            "SELECT COUNT(*) FILTER (WHERE os.estado_actual IN ('cotizado', 'esperando_respuesta')) AS cotizaciones,
                    COUNT(*) FILTER (WHERE os.estado_actual IN ('esperando_abono', 'en_revision_recepcion', 'listo_para_entregar')) AS acciones
             {$baseFrom}
             WHERE c.ferreteria_id = ?"
        );
        $seccionesStmt->execute([$ferreteriaId]);
        $secciones = array_map('intval', $seccionesStmt->fetch(PDO::FETCH_ASSOC) ?: []);

        $opcionesStmt = $pdo->prepare(
            'SELECT DISTINCT os.tipo, COALESCE(os.ubicacion_actual, h_ubicacion.ubicacion, \'\') AS ubicacion
             ' . $baseFrom . '
             WHERE c.ferreteria_id = ?
             ORDER BY os.tipo, ubicacion'
        );
        $opcionesStmt->execute([$ferreteriaId]);
        foreach ($opcionesStmt->fetchAll(PDO::FETCH_ASSOC) as $opcion) {
            if ($opcion['tipo'] !== null && !in_array($opcion['tipo'], $tipos, true)) {
                $tipos[] = $opcion['tipo'];
            }
            if ($opcion['ubicacion'] !== '' && !in_array($opcion['ubicacion'], $ubicaciones, true)) {
                $ubicaciones[] = $opcion['ubicacion'];
            }
        }
    }

    return [
        'ordenes' => $ordenes,
        'pagina' => $pagina,
        'por_pagina' => $porPagina,
        'total' => $total,
        'total_paginas' => $totalPaginas,
        'conteos_estado' => $conteosEstados,
        'resumen' => $resumen,
        'secciones' => $secciones,
        'tipos' => $tipos,
        'ubicaciones' => $ubicaciones,
    ];
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

    $stmt = $pdo->prepare(
        'SELECT os.estado_actual
         FROM orden_servicio os
         JOIN articulo a ON a.id = os.articulo_id
         JOIN cliente c ON c.id = a.cliente_id
         WHERE os.id = ? AND c.ferreteria_id = ?'
    );
    $stmt->execute([$ordenId, (int) $usuarioAuth->ferreteria_id]);
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