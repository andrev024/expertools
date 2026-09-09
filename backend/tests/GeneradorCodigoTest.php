<?php

use PHPUnit\Framework\TestCase;
use App\GeneradorCodigo;

class GeneradorCodigoTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();
        GeneradorCodigo::resetSecuencia();
    }

    public function testGeneraConElPrefijoCorrecto(): void
    {
        $codigo = GeneradorCodigo::generarCodigoSeguimiento();

        $this->assertStringStartsWith('OT-A-', $codigo);
    }

    public function testGeneraUnConsecutivoConFormatoDeCuatroDigitos(): void
    {
        $codigo = GeneradorCodigo::generarCodigoSeguimiento();
        $parteNumerica = substr($codigo, 5);

        $this->assertMatchesRegularExpression('/^\d{4}$/', $parteNumerica);
        $this->assertGreaterThanOrEqual(600, (int) $parteNumerica);
    }

    public function testGeneraConsecutivosSiguientes(): void
    {
        $codigo1 = GeneradorCodigo::generarCodigoSeguimiento();
        $codigo2 = GeneradorCodigo::generarCodigoSeguimiento();
        $numero1 = (int) substr($codigo1, 5);
        $numero2 = (int) substr($codigo2, 5);

        $this->assertSame($numero1 + 1, $numero2);
    }

    public function testLaSecuenciaEmpiezaEn0600EnUnProcesoNuevo(): void
    {
        $codigo = GeneradorCodigo::generarCodigoSeguimiento();

        $this->assertSame('OT-A-0600', $codigo);
    }
}
