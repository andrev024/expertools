<?php

require_once __DIR__ . '/../src/bootstrap.php';

use App\Database;
use App\Middleware;
use App\R2Storage;
use Aws\Exception\AwsException;

$usuarioAuth = Middleware::requireAuth(['recepcion', 'admin', 'tecnico']);
$ferreteriaId = (int) $usuarioAuth->ferreteria_id;
$pdo = Database::getConnection();
$metodo = $_SERVER['REQUEST_METHOD'];
$logoActual = $pdo->prepare('SELECT logo_key FROM ferreteria WHERE id = ?');
$logoActual->execute([$ferreteriaId]);
$claveAnterior = $logoActual->fetchColumn();

if ($claveAnterior === false) {
    header('Content-Type: application/json; charset=utf-8');
    http_response_code(404);
    echo json_encode(['error' => 'Ferretería no encontrada']);
    exit;
}

if ($metodo === 'GET') {
    header('Content-Type: application/json; charset=utf-8');
    if (!$claveAnterior) {
        http_response_code(404);
        echo json_encode(['error' => 'Esta ferretería no tiene un logo configurado']);
        exit;
    }

    try {
        $objeto = (new R2Storage())->obtener($claveAnterior);
    } catch (RuntimeException $e) {
        error_log($e->getMessage());
        http_response_code(503);
        echo json_encode(['error' => 'El almacenamiento del logo no está configurado']);
        exit;
    } catch (AwsException $e) {
        error_log('No se pudo leer el logo desde R2: ' . $e->getMessage());
        http_response_code(502);
        echo json_encode(['error' => 'No se pudo obtener el logo desde el almacenamiento']);
        exit;
    }

    if (!in_array($objeto['tipo_contenido'], ['image/png', 'image/jpeg'], true)) {
        error_log('R2 devolvió un tipo de contenido inválido para el logo de ferretería ' . $ferreteriaId);
        http_response_code(502);
        echo json_encode(['error' => 'El archivo de logo almacenado no es válido']);
        exit;
    }

    header('Content-Type: ' . $objeto['tipo_contenido']);
    header('Cache-Control: private, max-age=300');
    header('X-Content-Type-Options: nosniff');
    echo $objeto['contenido'];
    exit;
}

if ($metodo === 'POST') {
    header('Content-Type: application/json; charset=utf-8');
    if (!in_array($usuarioAuth->rol, ['recepcion', 'admin'], true)) {
        http_response_code(403);
        echo json_encode(['error' => 'No tienes permiso para cambiar el logo']);
        exit;
    }

    if (!isset($_FILES['logo'])) {
        if ((int) ($_SERVER['CONTENT_LENGTH'] ?? 0) > 2 * 1024 * 1024 + 65536) {
            http_response_code(413);
            echo json_encode(['error' => 'El logo debe pesar como máximo 2 MB']);
            exit;
        }
        http_response_code(400);
        echo json_encode(['error' => 'Selecciona un archivo de logo']);
        exit;
    }

    $archivo = $_FILES['logo'];
    if ($archivo['error'] !== UPLOAD_ERR_OK) {
        http_response_code($archivo['error'] === UPLOAD_ERR_INI_SIZE || $archivo['error'] === UPLOAD_ERR_FORM_SIZE ? 413 : 400);
        echo json_encode(['error' => 'No se pudo recibir el archivo de logo']);
        exit;
    }

    $rutaTemporal = $archivo['tmp_name'];
    if (!is_uploaded_file($rutaTemporal)) {
        http_response_code(400);
        echo json_encode(['error' => 'El archivo recibido no es válido']);
        exit;
    }

    $tamanio = filesize($rutaTemporal);
    if ($tamanio === false || $tamanio < 1 || $tamanio > 2 * 1024 * 1024) {
        http_response_code(413);
        echo json_encode(['error' => 'El logo debe pesar como máximo 2 MB']);
        exit;
    }

    $finfo = new finfo(FILEINFO_MIME_TYPE);
    $tipoContenido = $finfo->file($rutaTemporal);
    $extensiones = ['image/png' => 'png', 'image/jpeg' => 'jpg'];
    $dimensiones = getimagesize($rutaTemporal);

    if (
        !isset($extensiones[$tipoContenido])
        || $dimensiones === false
        || $dimensiones['mime'] !== $tipoContenido
        || $dimensiones[0] > 4096
        || $dimensiones[1] > 4096
        || $dimensiones[0] * $dimensiones[1] > 16000000
    ) {
        http_response_code(400);
        echo json_encode(['error' => 'El logo debe ser una imagen PNG o JPEG válida, de hasta 4096 × 4096 píxeles']);
        exit;
    }

    $contenido = file_get_contents($rutaTemporal);
    if ($contenido === false) {
        http_response_code(400);
        echo json_encode(['error' => 'No se pudo leer el archivo de logo']);
        exit;
    }

    $claveNueva = sprintf(
        'ferreterias/%d/logos/%s.%s',
        $ferreteriaId,
        bin2hex(random_bytes(16)),
        $extensiones[$tipoContenido]
    );

    try {
        $almacenamiento = new R2Storage();
        $almacenamiento->guardar($claveNueva, $contenido, $tipoContenido);
    } catch (\RuntimeException $e) {
        error_log($e->getMessage());
        http_response_code(503);
        echo json_encode(['error' => 'El almacenamiento del logo no está configurado']);
        exit;
    } catch (AwsException $e) {
        error_log('No se pudo guardar el logo en R2: ' . $e->getMessage());
        http_response_code(502);
        echo json_encode(['error' => 'No se pudo guardar el logo en el almacenamiento']);
        exit;
    }

    try {
        $actualizar = $pdo->prepare('UPDATE ferreteria SET logo_key = ? WHERE id = ?');
        $actualizar->execute([$claveNueva, $ferreteriaId]);
    } catch (\PDOException $e) {
        try {
            $almacenamiento->eliminar($claveNueva);
        } catch (AwsException $errorLimpieza) {
            error_log('No se pudo limpiar un logo R2 sin referencia: ' . $errorLimpieza->getMessage());
        }
        error_log('No se pudo actualizar el logo de la ferretería: ' . $e->getMessage());
        http_response_code(500);
        echo json_encode(['error' => 'El logo se subió, pero no se pudo actualizar la configuración']);
        exit;
    }

    $aviso = null;
    if ($claveAnterior) {
        try {
            $almacenamiento->eliminar($claveAnterior);
        } catch (AwsException $e) {
            error_log('No se pudo borrar el logo anterior de R2: ' . $e->getMessage());
            $aviso = 'El logo se actualizó, pero no se pudo borrar la versión anterior del almacenamiento';
        }
    }

    echo json_encode(['actualizado' => true, 'aviso' => $aviso]);
    exit;
}

if ($metodo === 'DELETE') {
    header('Content-Type: application/json; charset=utf-8');
    if (!in_array($usuarioAuth->rol, ['recepcion', 'admin'], true)) {
        http_response_code(403);
        echo json_encode(['error' => 'No tienes permiso para quitar el logo']);
        exit;
    }

    $actualizar = $pdo->prepare('UPDATE ferreteria SET logo_key = NULL WHERE id = ?');
    $actualizar->execute([$ferreteriaId]);

    $aviso = null;
    if ($claveAnterior) {
        try {
            (new R2Storage())->eliminar($claveAnterior);
        } catch (\RuntimeException $e) {
            error_log($e->getMessage());
            $aviso = 'Se quitó el logo de la cuenta, pero el almacenamiento no está configurado';
        } catch (AwsException $e) {
            error_log('No se pudo borrar el logo de R2: ' . $e->getMessage());
            $aviso = 'Se quitó el logo de la cuenta, pero no se pudo borrar del almacenamiento';
        }
    }

    echo json_encode(['eliminado' => (bool) $claveAnterior, 'aviso' => $aviso]);
    exit;
}

http_response_code(405);
header('Content-Type: application/json; charset=utf-8');
header('Allow: GET, POST, DELETE');
echo json_encode(['error' => 'Método no permitido']);
