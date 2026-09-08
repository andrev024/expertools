<?php

require_once __DIR__ . '/../src/bootstrap.php';

use App\Database;
use App\Middleware;

Middleware::requireAuth(['recepcion', 'admin']);
$pdo = Database::getConnection();
$nombreArchivo = 'expertools-respaldo-' . date('Y-m-d-His') . '.sql';

header('Content-Type: application/sql; charset=utf-8');
header('Content-Disposition: attachment; filename="' . $nombreArchivo . '"');
header('Cache-Control: no-store');

echo "-- Respaldo Expertools\n";
echo '-- Generado: ' . date('Y-m-d H:i:s') . "\n\n";
echo "SET FOREIGN_KEY_CHECKS=0;\n\n";

$tablas = $pdo->query('SHOW TABLES')->fetchAll(PDO::FETCH_COLUMN);
foreach ($tablas as $tabla) {
    $tablaSql = str_replace('`', '``', $tabla);
    $estructura = $pdo->query("SHOW CREATE TABLE `{$tablaSql}`")->fetch(PDO::FETCH_ASSOC);
    $sentenciaCreate = $estructura['Create Table'] ?? $estructura['Create View'] ?? null;

    if ($sentenciaCreate) {
        echo "DROP TABLE IF EXISTS `{$tablaSql}`;\n";
        echo $sentenciaCreate . ";\n\n";
    }

    $filas = $pdo->query("SELECT * FROM `{$tablaSql}`")->fetchAll(PDO::FETCH_ASSOC);
    foreach ($filas as $fila) {
        $columnas = array_map(static fn (string $columna): string => '`' . str_replace('`', '``', $columna) . '`', array_keys($fila));
        $valores = array_map(static function ($valor) use ($pdo): string {
            return $valor === null ? 'NULL' : $pdo->quote((string) $valor);
        }, array_values($fila));
        echo 'INSERT INTO `' . $tablaSql . '` (' . implode(', ', $columnas) . ') VALUES (' . implode(', ', $valores) . ");\n";
    }
    echo "\n";
}

echo "SET FOREIGN_KEY_CHECKS=1;\n";
