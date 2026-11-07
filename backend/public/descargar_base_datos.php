<?php

require_once __DIR__ . '/../src/bootstrap.php';

use App\Database;
use App\Middleware;

$usuarioAuth = Middleware::requireAuth(['recepcion', 'admin']);
$ferreteriaId = (int) $usuarioAuth->ferreteria_id;
$pdo = Database::getConnection();

$consultas = [
    'ferreteria' => ['SELECT * FROM ferreteria WHERE id = ?', [$ferreteriaId]],
    'usuario' => ['SELECT * FROM usuario WHERE ferreteria_id = ?', [$ferreteriaId]],
    'cliente' => ['SELECT * FROM cliente WHERE ferreteria_id = ?', [$ferreteriaId]],
    'articulo' => [
        'SELECT a.* FROM articulo a
         JOIN cliente c ON c.id = a.cliente_id
         WHERE c.ferreteria_id = ?',
        [$ferreteriaId],
    ],
    'accesorio' => [
        'SELECT ac.* FROM accesorio ac
         JOIN articulo a ON a.id = ac.articulo_id
         JOIN cliente c ON c.id = a.cliente_id
         WHERE c.ferreteria_id = ?',
        [$ferreteriaId],
    ],
    'orden_servicio' => [
        'SELECT os.* FROM orden_servicio os
         JOIN articulo a ON a.id = os.articulo_id
         JOIN cliente c ON c.id = a.cliente_id
         WHERE c.ferreteria_id = ?
         ORDER BY os.id',
        [$ferreteriaId],
    ],
    'cotizacion' => [
        'SELECT co.* FROM cotizacion co
         JOIN orden_servicio os ON os.id = co.orden_id
         JOIN articulo a ON a.id = os.articulo_id
         JOIN cliente c ON c.id = a.cliente_id
         WHERE c.ferreteria_id = ?',
        [$ferreteriaId],
    ],
    'cotizacion_detalle' => [
        'SELECT cd.* FROM cotizacion_detalle cd
         JOIN cotizacion co ON co.id = cd.cotizacion_id
         JOIN orden_servicio os ON os.id = co.orden_id
         JOIN articulo a ON a.id = os.articulo_id
         JOIN cliente c ON c.id = a.cliente_id
         WHERE c.ferreteria_id = ?',
        [$ferreteriaId],
    ],
    'historial_estado' => [
        'SELECT h.* FROM historial_estado h
         JOIN orden_servicio os ON os.id = h.orden_id
         JOIN articulo a ON a.id = os.articulo_id
         JOIN cliente c ON c.id = a.cliente_id
         WHERE c.ferreteria_id = ?',
        [$ferreteriaId],
    ],
    'notificacion' => [
        'SELECT n.* FROM notificacion n
         JOIN orden_servicio os ON os.id = n.orden_id
         JOIN articulo a ON a.id = os.articulo_id
         JOIN cliente c ON c.id = a.cliente_id
         WHERE c.ferreteria_id = ?',
        [$ferreteriaId],
    ],
];

function obtenerEsquemaPostgresql(string $esquema): string
{
    $entorno = getenv();
    $entorno = is_array($entorno) ? $entorno : [];
    $entorno['PGPASSWORD'] = (string) env('DB_PASS', '');
    $entorno['PGSSLMODE'] = (string) env('DB_SSL_MODE', 'require');
    $rutaCertificado = env('DB_SSL_CA_PATH');
    if ($rutaCertificado) {
        $entorno['PGSSLROOTCERT'] = $rutaCertificado;
    }

    $comando = [
        'pg_dump',
        '--schema-only',
        '--no-owner',
        '--no-acl',
        '--schema',
        $esquema,
        '--host',
        (string) env('DB_HOST', 'localhost'),
        '--port',
        (string) env('DB_PORT', '5432'),
        '--username',
        (string) env('DB_USER', 'root'),
        '--dbname',
        (string) env('DB_NAME', 'taller_tracker'),
    ];
    $descriptores = [
        0 => ['pipe', 'r'],
        1 => ['pipe', 'w'],
        2 => ['pipe', 'w'],
    ];
    $proceso = proc_open($comando, $descriptores, $tuberias, null, $entorno, ['bypass_shell' => true]);
    if (!is_resource($proceso)) {
        throw new RuntimeException('No se pudo iniciar pg_dump para generar el esquema PostgreSQL.');
    }

    fclose($tuberias[0]);
    $salida = stream_get_contents($tuberias[1]);
    $error = stream_get_contents($tuberias[2]);
    fclose($tuberias[1]);
    fclose($tuberias[2]);
    $resultado = proc_close($proceso);

    if ($resultado !== 0 || $salida === false) {
        throw new RuntimeException('No se pudo generar el esquema PostgreSQL: ' . trim((string) $error));
    }

    return $salida;
}

$esPostgresql = $pdo->getAttribute(PDO::ATTR_DRIVER_NAME) === 'pgsql';
$esquema = $esPostgresql ? (string) $pdo->query('SELECT current_schema()')->fetchColumn() : null;
$tablasDisponibles = $esPostgresql
    ? $pdo->prepare(
        "SELECT table_name
         FROM information_schema.tables
         WHERE table_schema = ? AND table_type = 'BASE TABLE'
         ORDER BY table_name"
    )
    : $pdo->query('SHOW TABLES');
if ($esPostgresql) {
    $tablasDisponibles->execute([$esquema]);
}
$nombresTablas = $tablasDisponibles->fetchAll(PDO::FETCH_COLUMN);
$tablas = $esPostgresql
    ? array_values(array_intersect(array_keys($consultas), $nombresTablas))
    : $nombresTablas;

foreach ($nombresTablas as $tabla) {
    if (!isset($consultas[$tabla])) {
        throw new RuntimeException('No existe una consulta de respaldo aislada para la tabla ' . $tabla);
    }
}

$esquemaSql = $esPostgresql ? obtenerEsquemaPostgresql($esquema) : '';
$nombreArchivo = 'ferreteria-' . $ferreteriaId . '-respaldo-' . date('Y-m-d-His') . '.sql';
header('Content-Type: application/sql; charset=utf-8');
header('Content-Disposition: attachment; filename="' . $nombreArchivo . '"');
header('Cache-Control: no-store');

echo "-- Respaldo de datos de la ferretería {$ferreteriaId}\n";
echo '-- Generado: ' . date('Y-m-d H:i:s') . "\n";
echo "-- Restaurar únicamente en una base vacía; no elimina ni reemplaza tablas.\n\n";
if ($esPostgresql) {
    echo $esquemaSql . "\n";
} else {
    echo "SET FOREIGN_KEY_CHECKS=0;\n\n";
}

foreach ($tablas as $tabla) {
    if (!$esPostgresql) {
        $tablaSql = str_replace('`', '``', $tabla);
        $estructura = $pdo->query("SHOW CREATE TABLE `{$tablaSql}`")->fetch(PDO::FETCH_ASSOC);
        $sentenciaCreate = $estructura['Create Table'] ?? null;

        if ($sentenciaCreate) {
            $sentenciaCreate = preg_replace('/^CREATE TABLE /', 'CREATE TABLE IF NOT EXISTS ', $sentenciaCreate);
            $sentenciaCreate = preg_replace('/ AUTO_INCREMENT=\d+/', '', $sentenciaCreate);
            echo $sentenciaCreate . ";\n\n";
        }
    }

    [$sql, $parametros] = $consultas[$tabla];
    $stmt = $pdo->prepare($sql);
    $stmt->execute($parametros);
    while ($fila = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $columnas = array_map(static function (string $columna) use ($esPostgresql): string {
            $delimitador = $esPostgresql ? '"' : '`';
            return $delimitador . str_replace($delimitador, $delimitador . $delimitador, $columna) . $delimitador;
        }, array_keys($fila));
        $valores = array_map(
            static fn ($valor): string => $valor === null ? 'NULL' : $pdo->quote((string) $valor),
            array_values($fila)
        );
        $tablaSql = $esPostgresql
            ? '"' . str_replace('"', '""', $esquema) . '"."' . str_replace('"', '""', $tabla) . '"'
            : '`' . str_replace('`', '``', $tabla) . '`';
        echo 'INSERT INTO ' . $tablaSql . ' (' . implode(', ', $columnas) . ') VALUES ('
            . implode(', ', $valores) . ");\n";
    }
    echo "\n";

    if ($esPostgresql) {
        $consultaSecuencia = $pdo->prepare('SELECT pg_get_serial_sequence(?, ?)');
        $nombreTabla = '"' . str_replace('"', '""', $esquema) . '"."' . str_replace('"', '""', $tabla) . '"';
        $consultaSecuencia->execute([$nombreTabla, 'id']);
        $secuencia = $consultaSecuencia->fetchColumn();
        if ($secuencia) {
            $esquemaSqlId = '"' . str_replace('"', '""', $esquema) . '"';
            $tablaSqlId = '"' . str_replace('"', '""', $tabla) . '"';
            echo 'SELECT setval(' . $pdo->quote((string) $secuencia)
                . ', COALESCE((SELECT MAX("id") FROM ' . $esquemaSqlId . '.' . $tablaSqlId
                . '), 1), EXISTS (SELECT 1 FROM ' . $esquemaSqlId . '.' . $tablaSqlId . "));\n";
        }
    }
}

if (!$esPostgresql) {
    echo "SET FOREIGN_KEY_CHECKS=1;\n";
}
