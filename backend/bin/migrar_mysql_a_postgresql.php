<?php

if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}

require_once __DIR__ . '/../src/bootstrap.php';

const TABLAS_MIGRACION = [
    'ferreteria',
    'usuario',
    'cliente',
    'articulo',
    'orden_servicio',
    'accesorio',
    'cotizacion',
    'cotizacion_detalle',
    'historial_estado',
    'notificacion',
];

function leerConfiguracion(
    string $variable,
    string $etiqueta,
    ?string $predeterminado = null,
    bool $opcional = false
): string {
    $valor = env($variable, $predeterminado);
    if ($valor !== null && trim((string) $valor) !== '') {
        return trim((string) $valor);
    }

    fwrite(STDOUT, $etiqueta);
    $entrada = fgets(STDIN);
    if ($entrada === false) {
        throw new RuntimeException("Falta configurar {$variable}.");
    }
    if ($opcional && trim($entrada) === '') {
        return '';
    }
    if (trim($entrada) === '') {
        throw new RuntimeException("Falta configurar {$variable}.");
    }

    return trim($entrada);
}

function leerPasswordOculta(string $variable, string $etiqueta): string
{
    $valor = env($variable);
    if ($valor !== null) {
        return (string) $valor;
    }

    fwrite(STDOUT, $etiqueta);
    if (PHP_OS_FAMILY === 'Windows') {
        $comando = <<<'POWERSHELL'
$secure = Read-Host -Prompt 'Contraseña (entrada oculta)' -AsSecureString
$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
try { [Console]::Out.Write([Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)) }
finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
POWERSHELL;
        $proceso = proc_open(
            ['powershell.exe', '-NoLogo', '-NoProfile', '-Command', $comando],
            [
                0 => ['file', 'php://stdin', 'r'],
                1 => ['pipe', 'w'],
                2 => ['pipe', 'w'],
            ],
            $tuberias,
            null,
            null,
            ['bypass_shell' => true]
        );
        if (!is_resource($proceso)) {
            throw new RuntimeException('No se pudo abrir la entrada oculta de contraseña.');
        }

        $password = stream_get_contents($tuberias[1]);
        $error = stream_get_contents($tuberias[2]);
        fclose($tuberias[1]);
        fclose($tuberias[2]);
        $resultado = proc_close($proceso);
        if ($resultado !== 0 || $password === false) {
            throw new RuntimeException('No se pudo leer la contraseña de forma segura: ' . trim((string) $error));
        }

        return $password;
    }

    $proceso = proc_open(
        ['stty', '-echo'],
        [
            0 => ['file', 'php://stdin', 'r'],
            1 => ['file', 'php://stdout', 'w'],
            2 => ['file', 'php://stderr', 'w'],
        ],
        $tuberias
    );
    if (!is_resource($proceso) || proc_close($proceso) !== 0) {
        throw new RuntimeException('No fue posible ocultar la contraseña en esta terminal.');
    }

    try {
        $password = fgets(STDIN);
    } finally {
        $proceso = proc_open(
            ['stty', 'echo'],
            [
                0 => ['file', 'php://stdin', 'r'],
                1 => ['file', 'php://stdout', 'w'],
                2 => ['file', 'php://stderr', 'w'],
            ],
            $tuberias
        );
        if (is_resource($proceso)) {
            proc_close($proceso);
        }
        fwrite(STDOUT, PHP_EOL);
    }

    if ($password === false) {
        throw new RuntimeException('No se pudo leer la contraseña de la terminal.');
    }

    return rtrim($password, "\r\n");
}

function generarSentencias(string $sql): Generator
{
    $inicio = 0;
    $largo = strlen($sql);
    $estado = 'normal';

    for ($i = 0; $i < $largo; $i++) {
        $actual = $sql[$i];
        $siguiente = $sql[$i + 1] ?? '';

        if ($estado === 'comilla_simple' || $estado === 'comilla_doble') {
            $comilla = $estado === 'comilla_simple' ? "'" : '"';
            if ($actual === '\\') {
                $i++;
            } elseif ($actual === $comilla && $siguiente === $comilla) {
                $i++;
            } elseif ($actual === $comilla) {
                $estado = 'normal';
            }
            continue;
        }
        if ($estado === 'backtick') {
            if ($actual === '`' && $siguiente === '`') {
                $i++;
            } elseif ($actual === '`') {
                $estado = 'normal';
            }
            continue;
        }
        if ($estado === 'linea') {
            if ($actual === "\n") {
                $estado = 'normal';
            }
            continue;
        }
        if ($estado === 'comentario') {
            if ($actual === '*' && $siguiente === '/') {
                $i++;
                $estado = 'normal';
            }
            continue;
        }

        if ($actual === "'") {
            $estado = 'comilla_simple';
        } elseif ($actual === '"') {
            $estado = 'comilla_doble';
        } elseif ($actual === '`') {
            $estado = 'backtick';
        } elseif ($actual === '#' || ($actual === '-' && $siguiente === '-' && ctype_space($sql[$i + 2] ?? ' '))) {
            $estado = 'linea';
            if ($actual === '-') {
                $i++;
            }
        } elseif ($actual === '/' && $siguiente === '*') {
            $estado = 'comentario';
            $i++;
        } elseif ($actual === ';') {
            yield substr($sql, $inicio, $i - $inicio + 1);
            $inicio = $i + 1;
        }
    }

    if (trim(substr($sql, $inicio)) !== '') {
        yield substr($sql, $inicio);
    }
}

function extraerInsert(string $sentencia): ?array
{
    $sentencia = preg_replace(
        '/\A(?:\s+|--[^\r\n]*(?:\r?\n|\z)|\#[^\r\n]*(?:\r?\n|\z)|\/\*.*?\*\/)*/s',
        '',
        $sentencia
    );
    if (!preg_match(
        '/^\s*INSERT\s+INTO\s+`([^`]+)`\s*\((.*?)\)\s*VALUES\s*(.*)\s*;?\s*$/is',
        $sentencia,
        $coincidencias
    )) {
        if (preg_match('/^\s*INSERT\s+INTO\b/i', $sentencia)) {
            throw new RuntimeException('El respaldo contiene un INSERT con formato no reconocido.');
        }
        return null;
    }

    preg_match_all('/`([^`]+)`/', $coincidencias[2], $columnas);
    if ($columnas[1] === []) {
        throw new RuntimeException('El respaldo contiene un INSERT sin columnas explícitas.');
    }

    return [$coincidencias[1], $columnas[1], $coincidencias[3]];
}

function saltarEspacios(string $texto, int &$posicion): void
{
    $largo = strlen($texto);
    while ($posicion < $largo && ctype_space($texto[$posicion])) {
        $posicion++;
    }
}

function leerValorSql(string $texto, int &$posicion): mixed
{
    saltarEspacios($texto, $posicion);
    $largo = strlen($texto);
    $actual = $texto[$posicion] ?? '';

    if ($actual === "'") {
        $posicion++;
        $valor = '';
        while ($posicion < $largo) {
            $actual = $texto[$posicion++];
            if ($actual === '\\') {
                if ($posicion >= $largo) {
                    throw new RuntimeException('Cadena truncada en el respaldo MySQL.');
                }
                $escape = $texto[$posicion++];
                $valor .= match ($escape) {
                    '0' => "\0",
                    'b' => "\x08",
                    'n' => "\n",
                    'r' => "\r",
                    't' => "\t",
                    'Z' => "\x1a",
                    default => $escape,
                };
            } elseif ($actual === "'") {
                if (($texto[$posicion] ?? '') === "'") {
                    $valor .= "'";
                    $posicion++;
                } else {
                    return $valor;
                }
            } else {
                $valor .= $actual;
            }
        }
        throw new RuntimeException('Cadena sin cerrar en el respaldo MySQL.');
    }

    $inicio = $posicion;
    while ($posicion < $largo && !in_array($texto[$posicion], [',', ')'], true)) {
        $posicion++;
    }
    $token = trim(substr($texto, $inicio, $posicion - $inicio));
    if (strcasecmp($token, 'NULL') === 0) {
        return null;
    }
    if (!preg_match('/^[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?$/D', $token)) {
        throw new RuntimeException('El respaldo contiene un valor SQL no admitido.');
    }

    return $token;
}

function procesarValoresInsert(string $valores, callable $alFila): int
{
    $posicion = 0;
    $largo = strlen($valores);
    $filas = 0;

    while (true) {
        saltarEspacios($valores, $posicion);
        if ($posicion >= $largo || $valores[$posicion] === ';') {
            return $filas;
        }
        if ($valores[$posicion] !== '(') {
            throw new RuntimeException('Lista de valores no reconocida en el respaldo MySQL.');
        }
        $posicion++;
        $fila = [];

        while (true) {
            $fila[] = leerValorSql($valores, $posicion);
            saltarEspacios($valores, $posicion);
            $separador = $valores[$posicion] ?? '';
            if ($separador === ',') {
                $posicion++;
                continue;
            }
            if ($separador !== ')') {
                throw new RuntimeException('Fila incompleta en el respaldo MySQL.');
            }
            $posicion++;
            break;
        }

        $alFila($fila);
        $filas++;
        saltarEspacios($valores, $posicion);
        if (($valores[$posicion] ?? '') === ',') {
            $posicion++;
            continue;
        }
        if ($posicion >= $largo || ($valores[$posicion] ?? '') === ';') {
            return $filas;
        }
        throw new RuntimeException('Separador de filas no reconocido en el respaldo MySQL.');
    }
}

function crearConexionPostgresql(): PDO
{
    $host = leerConfiguracion('MIGRATION_PG_HOST', 'Host PostgreSQL de Aiven: ');
    $port = leerConfiguracion('MIGRATION_PG_PORT', 'Puerto PostgreSQL de Aiven: ', '5432');
    $dbname = leerConfiguracion('MIGRATION_PG_DB', 'Nombre de base PostgreSQL: ', 'defaultdb');
    $user = leerConfiguracion('MIGRATION_PG_USER', 'Usuario PostgreSQL: ');
    $password = leerPasswordOculta('MIGRATION_PG_PASS', 'Contraseña PostgreSQL (entrada oculta): ');
    $sslMode = env('MIGRATION_PG_SSL_MODE', 'require');
    if (!in_array($sslMode, ['require', 'verify-full', 'disable'], true)) {
        throw new RuntimeException('MIGRATION_PG_SSL_MODE debe ser require, verify-full o disable.');
    }
    $ca = leerConfiguracion(
        'MIGRATION_PG_SSL_CA_PATH',
        'Ruta del certificado CA de PostgreSQL (Enter para sslmode=require): ',
        null,
        true
    );

    $dsn = "pgsql:host={$host};port={$port};dbname={$dbname}";
    if ($ca !== '') {
        if (!is_file($ca)) {
            throw new RuntimeException('El certificado CA de PostgreSQL configurado no existe.');
        }
        $sslMode = 'verify-full';
    }
    $dsn .= ";sslmode={$sslMode}";
    if ($ca !== '') {
        $dsn .= ";sslrootcert={$ca}";
    }

    return new PDO(
        $dsn,
        $user,
        $password,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]
    );
}

function obtenerTablasPostgresql(PDO $postgres): array
{
    return array_map(
        'strval',
        $postgres->query(
            "SELECT table_name FROM information_schema.tables
             WHERE table_schema = current_schema() AND table_type = 'BASE TABLE'
             ORDER BY table_name"
        )->fetchAll(PDO::FETCH_COLUMN)
    );
}

function validarEsquema(PDO $postgres): void
{
    $esperadas = TABLAS_MIGRACION;
    sort($esperadas);
    if (obtenerTablasPostgresql($postgres) !== $esperadas) {
        throw new RuntimeException(
            'PostgreSQL no contiene exactamente las diez tablas esperadas. Aplica schema_postgresql.sql primero.'
        );
    }

    foreach (TABLAS_MIGRACION as $tabla) {
        $tablaSql = '"public"."' . str_replace('"', '""', $tabla) . '"';
        if ((bool) $postgres->query("SELECT EXISTS (SELECT 1 FROM {$tablaSql})")->fetchColumn()) {
            throw new RuntimeException(
                "La tabla PostgreSQL {$tabla} ya contiene datos. El destino debe estar vacío; no se modificó."
            );
        }
    }
}

function insertarFilasEnBloque(
    PDO $postgres,
    string $tabla,
    array $columnas,
    array $filas
): int {
    if ($filas === []) {
        return 0;
    }

    $tablaSql = '"public"."' . str_replace('"', '""', $tabla) . '"';
    $columnasSql = array_map(
        static fn (string $columna): string => '"' . str_replace('"', '""', $columna) . '"',
        $columnas
    );
    $marcadorFila = '(' . implode(', ', array_fill(0, count($columnas), '?')) . ')';
    $sql = 'INSERT INTO ' . $tablaSql . ' (' . implode(', ', $columnasSql) . ')
            VALUES ' . implode(', ', array_fill(0, count($filas), $marcadorFila));
    $stmt = $postgres->prepare($sql);

    $parametro = 1;
    foreach ($filas as $fila) {
        if (count($fila) !== count($columnas)) {
            throw new RuntimeException("Una fila del respaldo tiene columnas incompletas en {$tabla}.");
        }
        foreach ($fila as $valor) {
            $stmt->bindValue($parametro++, $valor, $valor === null ? PDO::PARAM_NULL : PDO::PARAM_STR);
        }
    }
    $stmt->execute();

    return count($filas);
}

function importarRespaldo(PDO $postgres, string $contenido, array $conteos): void
{
    $columnasDestino = [];
    foreach (TABLAS_MIGRACION as $tabla) {
        $stmt = $postgres->prepare(
            'SELECT column_name FROM information_schema.columns
             WHERE table_schema = current_schema() AND table_name = ?
             ORDER BY ordinal_position'
        );
        $stmt->execute([$tabla]);
        $columnasDestino[$tabla] = array_map('strval', $stmt->fetchAll(PDO::FETCH_COLUMN));
    }

    $ordenTablas = array_flip(TABLAS_MIGRACION);
    $postgres->beginTransaction();
    try {
        $copiados = array_fill_keys(TABLAS_MIGRACION, 0);
        $definicionesInsert = [];
        $insertsPorTabla = array_fill_keys(TABLAS_MIGRACION, []);

        foreach (generarSentencias($contenido) as $sentencia) {
            $insert = extraerInsert($sentencia);
            if ($insert === null) {
                continue;
            }

            [$tabla, $columnas, $valores] = $insert;
            if (!isset($ordenTablas[$tabla])) {
                throw new RuntimeException("El respaldo contiene una tabla INSERT no esperada: {$tabla}.");
            }
            if (!isset($definicionesInsert[$tabla])) {
                $esperadas = $columnasDestino[$tabla];
                $recibidas = $columnas;
                sort($esperadas);
                sort($recibidas);
                if ($esperadas !== $recibidas) {
                    throw new RuntimeException("Las columnas del respaldo para {$tabla} no coinciden con PostgreSQL.");
                }
                $definicionesInsert[$tabla] = $columnas;
            } elseif ($definicionesInsert[$tabla] !== $columnas) {
                throw new RuntimeException("El respaldo contiene formatos de columnas diferentes para {$tabla}.");
            }

            $insertsPorTabla[$tabla][] = [$columnas, $valores];
        }

        foreach (TABLAS_MIGRACION as $tabla) {
            $buffer = [];
            foreach ($insertsPorTabla[$tabla] as [$columnas, $valores]) {
                procesarValoresInsert(
                    $valores,
                    static function (array $fila) use (
                        $tabla,
                        $columnas,
                        &$buffer,
                        &$copiados,
                        $conteos,
                        $definicionesInsert,
                        $postgres
                    ): void {
                        if (count($fila) !== count($columnas)) {
                            throw new RuntimeException("Una fila del respaldo tiene columnas incompletas en {$tabla}.");
                        }
                        if ($copiados[$tabla] + count($buffer) >= $conteos[$tabla]) {
                            throw new RuntimeException("El respaldo cambió durante la lectura de {$tabla}.");
                        }
                        $buffer[] = $fila;
                        if (count($buffer) >= 200) {
                            $copiados[$tabla] += insertarFilasEnBloque(
                                $postgres,
                                $tabla,
                                $definicionesInsert[$tabla],
                                $buffer
                            );
                            $buffer = [];
                            fwrite(STDOUT, "  {$tabla}: {$copiados[$tabla]} registros..." . PHP_EOL);
                            flush();
                        }
                    }
                );
            }
            if ($buffer !== []) {
                $copiados[$tabla] += insertarFilasEnBloque(
                    $postgres,
                    $tabla,
                    $definicionesInsert[$tabla],
                    $buffer
                );
                fwrite(STDOUT, "  {$tabla}: {$copiados[$tabla]} registros..." . PHP_EOL);
                flush();
            }
        }

        foreach ($conteos as $tabla => $esperado) {
            if ($copiados[$tabla] !== $esperado) {
                throw new RuntimeException("El conteo importado de {$tabla} no coincide con el respaldo.");
            }
            $tablaSql = '"public"."' . str_replace('"', '""', $tabla) . '"';
            $actual = (int) $postgres->query("SELECT COUNT(*) FROM {$tablaSql}")->fetchColumn();
            if ($actual !== $esperado) {
                throw new RuntimeException("El conteo final de {$tabla} no coincide.");
            }

            $secuenciaStmt = $postgres->prepare('SELECT pg_get_serial_sequence(?, ?)');
            $secuenciaStmt->execute([$tabla, 'id']);
            $secuencia = $secuenciaStmt->fetchColumn();
            if ($secuencia !== false && $secuencia !== null) {
                $secuenciaSql = $postgres->quote((string) $secuencia) . '::regclass';
                $postgres->exec(
                    "SELECT setval({$secuenciaSql}, COALESCE((SELECT MAX(\"id\") FROM {$tablaSql}), 1),
                     EXISTS (SELECT 1 FROM {$tablaSql}))"
                );
            }
        }

        $postgres->commit();
        foreach (TABLAS_MIGRACION as $tabla) {
            fwrite(STDOUT, "Importada {$tabla}: {$copiados[$tabla]} registros" . PHP_EOL);
        }
    } catch (Throwable $e) {
        if ($postgres->inTransaction()) {
            $postgres->rollBack();
        }
        throw $e;
    }
}

try {
    $rutaRespaldo = leerConfiguracion(
        'MIGRATION_MYSQL_DUMP',
        'Ruta del respaldo MySQL [database/schema_actual.sql]: ',
        'database/schema_actual.sql'
    );
    if (!is_file($rutaRespaldo) || !is_readable($rutaRespaldo)) {
        throw new RuntimeException('No se puede leer el archivo de respaldo MySQL configurado.');
    }

    $contenido = file_get_contents($rutaRespaldo);
    if ($contenido === false || $contenido === '') {
        throw new RuntimeException('El archivo de respaldo MySQL está vacío o no se pudo leer.');
    }

    $conteos = array_fill_keys(TABLAS_MIGRACION, 0);
    foreach (generarSentencias($contenido) as $sentencia) {
        $insert = extraerInsert($sentencia);
        if ($insert === null) {
            continue;
        }
        [$tabla, , $valores] = $insert;
        if (!isset($conteos[$tabla])) {
            throw new RuntimeException("El respaldo contiene una tabla INSERT no esperada: {$tabla}.");
        }
        $conteos[$tabla] += procesarValoresInsert($valores, static function (): void {
        });
    }

    $postgres = crearConexionPostgresql();
    validarEsquema($postgres);

    fwrite(STDOUT, PHP_EOL . "Origen: archivo local {$rutaRespaldo}" . PHP_EOL);
    fwrite(STDOUT, 'Destino: PostgreSQL de Aiven' . PHP_EOL);
    fwrite(STDOUT, 'Registros detectados en el respaldo:' . PHP_EOL);
    foreach (TABLAS_MIGRACION as $tabla) {
        fwrite(STDOUT, "  {$tabla}: {$conteos[$tabla]}" . PHP_EOL);
    }
    fwrite(STDOUT, PHP_EOL . "El destino PostgreSQL está vacío. Escribe IMPORTAR DATOS para confirmar: ");
    $confirmacion = fgets(STDIN);
    if ($confirmacion === false || trim($confirmacion) !== 'IMPORTAR DATOS') {
        throw new RuntimeException('Operación cancelada; no se copiaron datos.');
    }

    importarRespaldo($postgres, $contenido, $conteos);
    fwrite(STDOUT, PHP_EOL . 'Importación completa: el archivo MySQL se importó y los conteos coinciden.' . PHP_EOL);
    fwrite(STDOUT, "El archivo de respaldo no se modificó. La base MySQL original permanece intacta." . PHP_EOL);
} catch (Throwable $e) {
    if ($e instanceof PDOException) {
        fwrite(
            STDERR,
            'Importación detenida por un error de base de datos (SQLSTATE '
                . (string) $e->getCode()
                . '). No se muestran valores del respaldo.' . PHP_EOL
        );
    } else {
        fwrite(STDERR, 'Importación detenida: ' . $e->getMessage() . PHP_EOL);
    }
    exit(1);
}
