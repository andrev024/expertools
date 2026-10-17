<?php

namespace App;

use PDO;
use PDOException;
use RuntimeException;
use Throwable;

class FerreteriaProvisioner
{
    public static function validarDatos(
        string $slug,
        string $nombreComercial,
        string $codigoPrefijo,
        string $nombreAdministrador,
        string $email,
        string $password
    ): void {
        if (!preg_match('/^[a-z0-9]+(?:-[a-z0-9]+)*$/D', $slug)) {
            throw new RuntimeException('El slug debe usar minúsculas, números y guiones, sin guiones al inicio o al final.');
        }

        self::validarTexto($nombreComercial, 150, 'El nombre comercial');
        self::validarTexto($nombreAdministrador, 100, 'El nombre del administrador');

        if (
            !preg_match('/^[A-Za-z0-9][A-Za-z0-9._-]*$/D', $codigoPrefijo)
            || strlen($codigoPrefijo) > 16
        ) {
            throw new RuntimeException('El prefijo solo puede usar letras, números, punto, guion y guion bajo; máximo 16 caracteres.');
        }
        GeneradorCodigo::formatearCodigo($codigoPrefijo, 600);

        if (strlen($email) > 150 || filter_var($email, FILTER_VALIDATE_EMAIL) === false) {
            throw new RuntimeException('El correo del administrador no es válido o excede 150 caracteres.');
        }

        $caracteresPassword = preg_match_all('/./us', $password, $coincidencias);
        if ($caracteresPassword === false || $caracteresPassword < 12) {
            throw new RuntimeException('La contraseña inicial debe tener al menos 12 caracteres.');
        }
    }

    public static function crear(
        PDO $pdo,
        string $slug,
        string $nombreComercial,
        string $codigoPrefijo,
        string $nombreAdministrador,
        string $email,
        string $password
    ): int {
        self::validarDatos(
            $slug,
            $nombreComercial,
            $codigoPrefijo,
            $nombreAdministrador,
            $email,
            $password
        );
        self::validarEsquemaMigrado($pdo);

        try {
            $pdo->beginTransaction();

            $crearFerreteria = $pdo->prepare(
                'INSERT INTO ferreteria
                    (slug, nombre_comercial, codigo_prefijo, siguiente_consecutivo)
                 VALUES (?, ?, ?, 600)'
            );
            $crearFerreteria->execute([$slug, $nombreComercial, $codigoPrefijo]);
            $ferreteriaId = (int) $pdo->lastInsertId();

            $crearAdministrador = $pdo->prepare(
                'INSERT INTO usuario
                    (ferreteria_id, nombre, email, password_hash, rol)
                 VALUES (?, ?, ?, ?, ?)'
            );
            $crearAdministrador->execute([
                $ferreteriaId,
                $nombreAdministrador,
                $email,
                password_hash($password, PASSWORD_DEFAULT),
                'admin',
            ]);

            $pdo->commit();
            return $ferreteriaId;
        } catch (PDOException $e) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }

            if ((string) $e->getCode() === '23000') {
                throw new RuntimeException(
                    'Ese slug ya existe o el correo ya está registrado en otra ferretería. No se creó la cuenta.',
                    0,
                    $e
                );
            }

            throw new RuntimeException('No se pudo crear la ferretería y su administrador.', 0, $e);
        } catch (Throwable $e) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            throw $e;
        }
    }

    private static function validarEsquemaMigrado(PDO $pdo): void
    {
        $stmt = $pdo->prepare(
            'SELECT COUNT(*)
             FROM information_schema.tables
             WHERE table_schema = DATABASE()
               AND table_name = ?'
        );
        $stmt->execute(['ferreteria']);
        if ((int) $stmt->fetchColumn() !== 1) {
            throw new RuntimeException('La tabla ferreteria no existe. Primero aplica y valida la migración multiempresa.');
        }

        $stmt = $pdo->prepare(
            'SELECT COUNT(*)
             FROM information_schema.columns
             WHERE table_schema = DATABASE()
               AND table_name = ?
               AND column_name = ?'
        );
        $stmt->execute(['usuario', 'ferreteria_id']);
        if ((int) $stmt->fetchColumn() !== 1) {
            throw new RuntimeException('Falta usuario.ferreteria_id. Primero aplica y valida la migración multiempresa.');
        }
    }

    private static function validarTexto(string $valor, int $maximo, string $campo): void
    {
        $caracteres = preg_match_all('/./us', trim($valor), $coincidencias);
        if ($caracteres === false || $caracteres < 1 || $caracteres > $maximo) {
            throw new RuntimeException("{$campo} es obligatorio y admite hasta {$maximo} caracteres.");
        }
    }
}
