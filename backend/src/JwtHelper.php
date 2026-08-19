<?php

namespace App;

use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Exception;

class JwtHelper
{
    // Genera un token para un usuario recién autenticado.
    // "sub" (subject) = id del usuario, "rol" = para autorización por rol.
    public static function generar(int $usuarioId, string $rol): string
    {
        $secret = env('JWT_SECRET');
        $expSegundos = (int) (env('JWT_EXPIRATION_SECONDS') ?: 28800);

        $payload = [
            'sub' => $usuarioId,
            'rol' => $rol,
            'iat' => time(),                  // issued at (cuándo se creó)
            'exp' => time() + $expSegundos,    // expiration (cuándo caduca)
        ];

        return JWT::encode($payload, $secret, 'HS256');
    }

    // Verifica un token recibido. Devuelve el payload decodificado
    // o lanza una excepción si es inválido/expirado.
    public static function verificar(string $token): object
    {
        $secret = env('JWT_SECRET');

        try {
            return JWT::decode($token, new Key($secret, 'HS256'));
        } catch (Exception $e) {
            throw new Exception('Token inválido o expirado');
        }
    }

    // Extrae el token del header "Authorization: Bearer <token>"
    public static function obtenerTokenDeHeader(): ?string
    {
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? null;

        if ($authHeader && preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
            return $matches[1];
        }

        return null;
    }
}
