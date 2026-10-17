<?php

use App\FerreteriaProvisioner;
use PHPUnit\Framework\TestCase;

class FerreteriaProvisionerTest extends TestCase
{
    public function testAceptaLosDatosDeUnaFerreteriaYAdministrador(): void
    {
        $this->assertNull(FerreteriaProvisioner::validarDatos(
            'ferreteria-central',
            'Ferretería Central',
            'OT-B-',
            'Ana Pérez',
            'ana@example.com',
            'una-clave-segura-123'
        ));
    }

    public function testRechazaSlugsQueNoSonSegurosParaUrls(): void
    {
        $this->expectException(RuntimeException::class);
        FerreteriaProvisioner::validarDatos(
            '../otra-cuenta',
            'Ferretería Central',
            'OT-B-',
            'Ana Pérez',
            'ana@example.com',
            'una-clave-segura-123'
        );
    }

    public function testRechazaPrefijosMayoresAlLimiteDeLaColumna(): void
    {
        $this->expectException(RuntimeException::class);
        FerreteriaProvisioner::validarDatos(
            'ferreteria-central',
            'Ferretería Central',
            'PREFIJO-123456789',
            'Ana Pérez',
            'ana@example.com',
            'una-clave-segura-123'
        );
    }

    public function testRechazaContraseñasCortas(): void
    {
        $this->expectException(RuntimeException::class);
        FerreteriaProvisioner::validarDatos(
            'ferreteria-central',
            'Ferretería Central',
            'OT-B-',
            'Ana Pérez',
            'ana@example.com',
            'corta'
        );
    }
}
