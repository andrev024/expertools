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
         WHERE c.ferreteria_id = ?',
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

$nombreArchivo = 'ferreteria-' . $ferreteriaId . '-respaldo-' . date('Y-m-d-His') . '.sql';
header('Content-Type: application/sql; charset=utf-8');
header('Content-Disposition: attachment; filename="' . $nombreArchivo . '"');
header('Cache-Control: no-store');

echo "-- Respaldo de datos de la ferretería {$ferreteriaId}\n";
echo '-- Generado: ' . date('Y-m-d H:i:s') . "\n";
echo "-- Restaurar únicamente en una base vacía; no elimina ni reemplaza tablas.\n\n";
echo "SET FOREIGN_KEY_CHECKS=0;\n\n";

$tablas = $pdo->query('SHOW TABLES')->fetchAll(PDO::FETCH_COLUMN);
foreach ($tablas as $tabla) {
    if (!isset($consultas[$tabla])) {
        throw new RuntimeException('No existe una consulta de respaldo aislada para la tabla ' . $tabla);
    }

    $tablaSql = str_replace('`', '``', $tabla);
    $estructura = $pdo->query("SHOW CREATE TABLE `{$tablaSql}`")->fetch(PDO::FETCH_ASSOC);
    $sentenciaCreate = $estructura['Create Table'] ?? null;

    if ($sentenciaCreate) {
        $sentenciaCreate = preg_replace('/^CREATE TABLE /', 'CREATE TABLE IF NOT EXISTS ', $sentenciaCreate);
        $sentenciaCreate = preg_replace('/ AUTO_INCREMENT=\d+/', '', $sentenciaCreate);
        echo $sentenciaCreate . ";\n\n";
    }

    [$sql, $parametros] = $consultas[$tabla];
    $stmt = $pdo->prepare($sql);
    $stmt->execute($parametros);
    while ($fila = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $columnas = array_map(
            static fn (string $columna): string => '`' . str_replace('`', '``', $columna) . '`',
            array_keys($fila)
        );
        $valores = array_map(
            static fn ($valor): string => $valor === null ? 'NULL' : $pdo->quote((string) $valor),
            array_values($fila)
        );
        echo 'INSERT INTO `' . $tablaSql . '` (' . implode(', ', $columnas) . ') VALUES ('
            . implode(', ', $valores) . ");\n";
    }
    echo "\n";
}

echo "SET FOREIGN_KEY_CHECKS=1;\n";
