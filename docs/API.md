# API REST

La API esta publicada bajo `backend/public/` y recibe solicitudes JSON. Las operaciones privadas requieren:

```http
Authorization: Bearer <token>
Content-Type: application/json
```

## Endpoints principales

| Recurso | Archivo | Uso |
|---|---|---|
| Autenticacion | `login.php` | Iniciar sesion y obtener JWT |
| Clientes | `clientes.php` | Consultar y registrar clientes |
| Articulos | `articulos.php` | Gestionar articulos de clientes |
| Ordenes | `ordenes.php` | Crear y consultar ordenes |
| Cotizaciones | `cotizacion.php` | Crear, consultar y editar cotizaciones |
| Estados | `cambiar_estado.php` | Avanzar una orden segun sus reglas |
| Historial | `historial.php` | Consultar trazabilidad de una orden |
| Seguimiento | `seguimiento.php` | Consulta publica por codigo |
| Usuarios | `usuarios.php` | Administracion de usuarios |

## Ejemplo de login

```http
POST /login.php
Content-Type: application/json

{"usuario":"recepcion","password":"tu-clave"}
```

La respuesta incluye un token JWT que debe enviarse en las siguientes solicitudes privadas. Los nombres exactos de campos y filtros deben consultarse en cada archivo PHP, que es la fuente de verdad del contrato actual.

## Seguimiento publico

```http
GET /seguimiento.php?codigo=<codigo_de_seguimiento>
```

Devuelve el estado publico, la linea de tiempo y, cuando existe, el diagnostico, los repuestos, el total, el abono y el estado de la cotizacion.
