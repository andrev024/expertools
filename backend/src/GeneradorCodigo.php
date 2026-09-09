<?php

namespace App;

class GeneradorCodigo
{
    private const PREFIJO = 'OT-A-';
    private const SECUENCIA_INICIAL = 600;

    private static ?int $secuencia = null;

    // Genera un codigo tipo OT-A-0600: prefijo fijo + consecutivo de 4 digitos.
    // Si se recibe una conexion, el consecutivo se calcula a partir de la BD
    // para que persista entre peticiones (PHP no conserva estado en memoria).
    public static function generarCodigoSeguimiento(?\PDO $pdo = null): string
    {
        if ($pdo !== null) {
            $siguiente = self::obtenerSiguienteDesdeBd($pdo);
            return self::PREFIJO . str_pad((string) $siguiente, 4, '0', STR_PAD_LEFT);
        }

        if (self::$secuencia === null) {
            self::$secuencia = self::SECUENCIA_INICIAL;
        } else {
            self::$secuencia++;
        }

        return self::PREFIJO . str_pad((string) self::$secuencia, 4, '0', STR_PAD_LEFT);
    }

    private static function obtenerSiguienteDesdeBd(\PDO $pdo): int
    {
        $stmt = $pdo->prepare(
            "SELECT MAX(CAST(SUBSTRING(codigo_seguimiento, ?) AS UNSIGNED))
             FROM orden_servicio
             WHERE codigo_seguimiento LIKE ?"
        );
        $stmt->execute([strlen(self::PREFIJO) + 1, self::PREFIJO . '%']);
        $ultimo = $stmt->fetchColumn();

        return $ultimo !== null && $ultimo !== false
            ? ((int) $ultimo) + 1
            : self::SECUENCIA_INICIAL;
    }

    public static function resetSecuencia(): void
    {
        self::$secuencia = null;
    }
}
