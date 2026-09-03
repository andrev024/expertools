<?php

use PHPUnit\Framework\TestCase;
use App\MaquinaEstados;

// Convención de PHPUnit: el nombre de la clase termina en "Test",
// y cada método de prueba empieza con "test".
class MaquinaEstadosTest extends TestCase
{
    public function testPermiteTransicionValida(): void
    {
        // Assert = "afirmo que esto debe ser verdadero". Si no lo es, el test falla.
        $this->assertTrue(
            MaquinaEstados::esTransicionValida('recibido', 'en_diagnostico')
        );
    }

    public function testRechazaTransicionInvalida(): void
    {
        // No se puede saltar de "recibido" directo a "entregado"
        $this->assertFalse(
            MaquinaEstados::esTransicionValida('recibido', 'entregado')
        );
    }

    public function testPermiteSalidaAChatarraDesdeDiagnostico(): void
    {
        $this->assertTrue(
            MaquinaEstados::esTransicionValida('en_diagnostico', 'chatarra')
        );
    }

    public function testEstadosPermitidosDesdeCotizadoIncluyenLosTresCaminos(): void
    {
        $permitidos = MaquinaEstados::estadosPermitidosDesde('cotizado');

        // assertContains: la lista debe incluir estos 3 valores
        $this->assertContains('en_reparacion', $permitidos);
        $this->assertContains('no_autorizado', $permitidos);
        $this->assertContains('sin_respuesta', $permitidos);
    }

    public function testSoloTecnicoPuedeMoverACotizado(): void
    {
        $this->assertTrue(MaquinaEstados::rolPuedeTransicionar('tecnico', 'cotizado'));
        $this->assertFalse(MaquinaEstados::rolPuedeTransicionar('recepcion', 'cotizado'));
    }

    public function testAdminPuedeCualquierTransicion(): void
    {
        // Admin es un caso especial: siempre puede, sin importar el estado destino
        $this->assertTrue(MaquinaEstados::rolPuedeTransicionar('admin', 'entregado'));
        $this->assertTrue(MaquinaEstados::rolPuedeTransicionar('admin', 'chatarra'));
    }

    public function testSoloRecepcionPuedeEntregar(): void
    {
        $this->assertTrue(MaquinaEstados::rolPuedeTransicionar('recepcion', 'entregado'));
        $this->assertFalse(MaquinaEstados::rolPuedeTransicionar('tecnico', 'entregado'));
    }
}
