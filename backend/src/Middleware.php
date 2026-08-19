<?php

namespace App;

use Exception;

class Middleware
{
    // Verifica el token y, si se pasan roles permitidos, que el usuario
    // tenga uno de esos roles. Si algo falla, corta la ejecución con 401/403.
    // Si todo está bien, devuelve el payload del token (sub, rol) para usarlo
    // en el endpoint (ej. para saber quién hizo el cambio de estado).
    public static function requireAuth(array $rolesPermitidos = []): object
    {
        $token = JwtHelper::obtenerTokenDeHeader();

        if (!$token) {
            http_response_code(401);
            die(json_encode(['error' => 'No se envió token de autenticación']));
        }

        try {
            $payload = JwtHelper::verificar($token);
        } catch (Exception $e) {
            http_response_code(401);
            die(json_encode(['error' => $e->getMessage()]));
        }

        if (!empty($rolesPermitidos) && !in_array($payload->rol, $rolesPermitidos)) {
            http_response_code(403);
            die(json_encode(['error' => 'No tienes permiso para esta acción']));
        }

        return $payload;
    }
}
