<?php

namespace App;

class GeneradorCodigo
{
    // Genera un codigo tipo TAL-A1B2C3: prefijo fijo + 6 caracteres hexadecimales en mayuscula
    public static function generarCodigoSeguimiento(): string
    {
        return 'TAL-' . strtoupper(substr(bin2hex(random_bytes(4)), 0, 6));
    }
}
