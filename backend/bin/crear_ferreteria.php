<?php

if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}

if (in_array('--help', $argv, true) || in_array('-h', $argv, true)) {
    echo "Uso: php bin/crear_ferreteria.php\n";
    echo "Pide los datos de la ferretería y crea su cuenta junto con el primer administrador.\n";
    echo "Requiere la migración multiempresa y una terminal interactiva.\n";
    exit(0);
}

if (count($argv) !== 1 || !function_exists('stream_isatty') || !stream_isatty(STDIN)) {
    fwrite(STDERR, "Este comando requiere una terminal interactiva. Usa --help para ver su propósito.\n");
    exit(2);
}

require_once __DIR__ . '/../src/bootstrap.php';

use App\Database;
use App\FerreteriaProvisioner;

function leerLinea(string $etiqueta): string
{
    fwrite(STDOUT, $etiqueta);
    $valor = fgets(STDIN);
    if ($valor === false) {
        throw new RuntimeException('No se pudo leer la respuesta de la terminal.');
    }

    return trim($valor);
}

function leerPasswordOculta(string $etiqueta): string
{
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
                2 => ['file', 'php://stderr', 'w'],
            ],
            $pipes,
            null,
            null,
            ['bypass_shell' => true]
        );
        if (!is_resource($proceso)) {
            throw new RuntimeException('No se pudo abrir la entrada oculta de contraseña.');
        }
        $password = stream_get_contents($pipes[1]);
        fclose($pipes[1]);
        $resultado = proc_close($proceso);
        if ($resultado !== 0 || $password === false) {
            throw new RuntimeException('No se pudo leer la contraseña de forma segura.');
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
        $pipes
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
            $pipes
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

try {
    $pdo = Database::getConnection();
    echo "Base de datos destino: " . env('DB_HOST', 'localhost') . " / " . $pdo->query('SELECT DATABASE()')->fetchColumn() . PHP_EOL;
    echo "La migración multiempresa debe estar aplicada antes de continuar." . PHP_EOL . PHP_EOL;

    $nombreComercial = leerLinea('Nombre comercial: ');
    $slug = leerLinea('Slug público (por ejemplo, ferreteria-central): ');
    $codigoPrefijo = leerLinea('Prefijo de órdenes (por ejemplo, OT-B-): ');
    $nombreAdministrador = leerLinea('Nombre del primer administrador: ');
    $email = strtolower(leerLinea('Correo del administrador (debe ser único en todo el sistema): '));
    $password = leerPasswordOculta('Contraseña inicial: ');
    $confirmacion = leerPasswordOculta('Confirma la contraseña: ');

    if (!hash_equals($password, $confirmacion)) {
        throw new RuntimeException('Las contraseñas no coinciden. No se creó la cuenta.');
    }

    echo PHP_EOL . "Se creará la ferretería '{$nombreComercial}' ({$slug}) y su primer administrador." . PHP_EOL;
    echo "El usuario inicial tendrá el rol admin; aún no se importarán datos históricos." . PHP_EOL;
    if (leerLinea("Escribe CREAR para confirmar: ") !== 'CREAR') {
        throw new RuntimeException('Operación cancelada. No se creó la cuenta.');
    }

    $ferreteriaId = FerreteriaProvisioner::crear(
        $pdo,
        $slug,
        $nombreComercial,
        $codigoPrefijo,
        $nombreAdministrador,
        $email,
        $password
    );

    echo "Ferretería creada correctamente. ID: {$ferreteriaId}. Guárdalo para preparar la importación histórica." . PHP_EOL;
} catch (Throwable $e) {
    fwrite(STDERR, 'No se creó la cuenta: ' . $e->getMessage() . PHP_EOL);
    exit(1);
}
