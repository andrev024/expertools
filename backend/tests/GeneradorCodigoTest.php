<?php

use PHPUnit\Framework\TestCase;
use App\GeneradorCodigo;

class GeneradorCodigoTest extends TestCase
{
    public function testRespetaElPrefijoConfigurado(): void
    {
        $codigo = GeneradorCodigo::formatearCodigo('OT-X-', 42);

        $this->assertSame('OT-X-0042', $codigo);
    }

    public function testFormateaCodigoConPrefijoYConsecutivo(): void
    {
        $codigo = GeneradorCodigo::formatearCodigo('OT-A-', 600);

        $this->assertSame('OT-A-0600', $codigo);
    }

    public function testConsecutivoDeMasDeCuatroDigitosNoSeTrunca(): void
    {
        $codigo = GeneradorCodigo::formatearCodigo('OT-A-', 12345);

        $this->assertSame('OT-A-12345', $codigo);
    }

    public function testRechazaUnConsecutivoInvalido(): void
    {
        $this->expectException(InvalidArgumentException::class);

        GeneradorCodigo::formatearCodigo('OT-A-', 0);
    }

    public function testRechazaCodigosQueExcedenLaColumnaDeBaseDeDatos(): void
    {
        $this->expectException(InvalidArgumentException::class);

        GeneradorCodigo::formatearCodigo('PREFIJO-DEMASIADO-LARGO-', 600);
    }
}
