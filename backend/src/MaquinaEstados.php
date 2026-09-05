<?php

namespace App;

class MaquinaEstados
{
    // Transiciones permitidas: estado_actual => [estados_a_los_que_puede_pasar]
    private static array $transiciones = [
        'recibido' => ['en_diagnostico'],
        'en_diagnostico' => ['chatarra', 'cotizado'],
        'cotizado' => ['en_reparacion', 'no_autorizado', 'esperando_respuesta', 'sin_respuesta'],
        'esperando_respuesta' => ['en_reparacion', 'no_autorizado'],
        'sin_respuesta' => ['en_diagnostico'],
        'en_reparacion' => ['esperando_repuesto', 'finalizado_tecnico'],
        'esperando_repuesto' => ['en_reparacion'],
        'finalizado_tecnico' => ['en_revision_recepcion'],
        'en_revision_recepcion' => ['listo_para_entregar'],
        'listo_para_entregar' => ['entregado'],
    ];

    // Quién puede mover a cada estado nuevo (aparte de admin, que siempre puede)
    private static array $rolesPorEstado = [
        'en_diagnostico' => ['tecnico'],
        'chatarra' => ['tecnico'],
        'cotizado' => ['tecnico'],
        'en_reparacion' => ['tecnico'],
        'no_autorizado' => ['tecnico', 'recepcion'],
        'esperando_respuesta' => ['tecnico'],
        'sin_respuesta' => ['tecnico', 'recepcion'],
        'esperando_repuesto' => ['tecnico'],
        'finalizado_tecnico' => ['tecnico'],
        'en_revision_recepcion' => ['tecnico'],
        'listo_para_entregar' => ['recepcion'],
        'entregado' => ['recepcion'],
    ];

    // ¿Se puede pasar de $estadoActual a $nuevoEstado?
    public static function esTransicionValida(string $estadoActual, string $nuevoEstado): bool
    {
        $permitidos = self::$transiciones[$estadoActual] ?? [];
        return in_array($nuevoEstado, $permitidos);
    }

    // Devuelve la lista de estados a los que se puede pasar desde uno dado
    public static function estadosPermitidosDesde(string $estadoActual): array
    {
        return self::$transiciones[$estadoActual] ?? [];
    }

    // ¿El rol dado puede ejecutar la transición hacia $nuevoEstado?
    public static function rolPuedeTransicionar(string $rol, string $nuevoEstado): bool
    {
        if ($rol === 'admin') {
            return true; // admin siempre puede
        }

        $rolesPermitidos = self::$rolesPorEstado[$nuevoEstado] ?? [];
        return in_array($rol, $rolesPermitidos);
    }
}
