<?php

use App\JwtHelper;
use PHPUnit\Framework\TestCase;

if (!function_exists('env')) {
    function env(string $key, $default = null)
    {
        return $_ENV[$key] ?? $_SERVER[$key] ?? (getenv($key) ?: $default);
    }
}

class JwtHelperTest extends TestCase
{
    protected function setUp(): void
    {
        putenv('JWT_SECRET=unit-test-secret-with-enough-length');
    }

    protected function tearDown(): void
    {
        putenv('JWT_SECRET');
    }

    public function testElTokenIncluyeLaFerreteriaDelUsuario(): void
    {
        $token = JwtHelper::generar(17, 4, 'admin');
        $payload = JwtHelper::verificar($token);

        $this->assertSame(17, $payload->sub);
        $this->assertSame(4, $payload->ferreteria_id);
        $this->assertSame('admin', $payload->rol);
    }
}
