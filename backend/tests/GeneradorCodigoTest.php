<?php

use PHPUnit\Framework\TestCase;
use App\GeneradorCodigo;

class GeneradorCodigoTest extends TestCase
{
    public function testGeneraConElPrefijoCorrecto(): void
    {
        $codigo = GeneradorCodigo::generarCodigoSeguimiento();

        // assertStringStartsWith: el string debe empezar exactamente asi
        $this->assertStringStartsWith('TAL-', $codigo);
    }

    public function testGeneraElLargoCorrecto(): void
    {
        $codigo = GeneradorCodigo::generarCodigoSeguimiento();

        // "TAL-" (4 caracteres) + 6 caracteres = 10 en total
        $this->assertEquals(10, strlen($codigo));
    }

    public function testGeneraCodigosDiferentesCadaVez(): void
    {
        $codigo1 = GeneradorCodigo::generarCodigoSeguimiento();
        $codigo2 = GeneradorCodigo::generarCodigoSeguimiento();

        // assertNotEquals: confirma que NO sean iguales
        // (con aleatoriedad real, la probabilidad de choque es extremadamente baja)
        $this->assertNotEquals($codigo1, $codigo2);
    }

    public function testSoloContieneMayusculasYNumerosDespuesDelPrefijo(): void
    {
        $codigo = GeneradorCodigo::generarCodigoSeguimiento();
        $parteAleatoria = substr($codigo, 4); // quita "TAL-"

        // assertMatchesRegularExpression: confirma que el string cumple un patron
        $this->assertMatchesRegularExpression('/^[A-F0-9]{6}$/', $parteAleatoria);
    }
}
