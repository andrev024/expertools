<?php

namespace App;

class GeneradorCodigo
{
    public static function generarCodigoSeguimiento(\PDO $pdo, int $ferreteriaId): string
    {
        if (!$pdo->inTransaction()) {
            throw new \LogicException('El consecutivo debe generarse dentro de una transacción');
        }

        $stmt = $pdo->prepare(
            'SELECT codigo_prefijo, siguiente_consecutivo
             FROM ferreteria
             WHERE id = ?
             FOR UPDATE'
        );
        $stmt->execute([$ferreteriaId]);
        $ferreteria = $stmt->fetch();
        if (!$ferreteria) {
            throw new \RuntimeException('No se encontró la ferretería para generar el código');
        }

        $consecutivo = (int) $ferreteria['siguiente_consecutivo'];
        if ($consecutivo < 1) {
            throw new \RuntimeException('El consecutivo configurado para la ferretería no es válido');
        }

        $update = $pdo->prepare(
            'UPDATE ferreteria SET siguiente_consecutivo = ? WHERE id = ?'
        );
        $update->execute([$consecutivo + 1, $ferreteriaId]);

        return self::formatearCodigo((string) $ferreteria['codigo_prefijo'], $consecutivo);
    }

    public static function formatearCodigo(string $prefijo, int $consecutivo): string
    {
        if ($prefijo === '' || $consecutivo < 1) {
            throw new \InvalidArgumentException('El prefijo y el consecutivo deben ser válidos');
        }

        $codigo = $prefijo . str_pad((string) $consecutivo, 4, '0', STR_PAD_LEFT);
        if (strlen($codigo) > 20) {
            throw new \InvalidArgumentException('El código excede el tamaño permitido por la base de datos');
        }

        return $codigo;
    }
}
