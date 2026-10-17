# API REST

La API esta publicada bajo `backend/public/` y recibe solicitudes JSON. Las operaciones privadas requieren un JWT. El token identifica al usuario, su rol
y la ferretería; el backend obtiene el ámbito de los datos desde ese token, no
desde un `ferreteria_id` enviado por el navegador.

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
| Marca | `marca.php` | Consultar y actualizar los datos comerciales de la ferretería |
| Logo | `marca_logo.php` | Subir, consultar o quitar el logo privado de la ferretería |

## Aislamiento por ferretería

Cada usuario pertenece a una sola ferretería. Clientes, artículos, órdenes,
cotizaciones e historial solo se consultan o modifican dentro de la ferretería
del usuario autenticado. La administración de usuarios también está limitada
a esa ferretería. Los identificadores de otras cuentas responden como recursos
no encontrados.

La configuración de marca y los logos también se limitan a la ferretería del
JWT. Los archivos se almacenan en un bucket privado de Cloudflare R2; el
backend los sirve solo a usuarios autenticados de esa cuenta. Recepción y
administradores pueden editar la marca; técnicos pueden leerla para generar
comprobantes.

El seguimiento público no requiere JWT y solo devuelve la información prevista
para el cliente. Los enlaces incluyen el `slug` de la ferretería para distinguir
códigos iguales entre cuentas.

## Ejemplo de login

```http
POST /login.php
Content-Type: application/json

{"email":"recepcion@example.com","password":"tu-clave"}
```

La respuesta incluye un token JWT que debe enviarse en las siguientes solicitudes privadas. Los nombres exactos de campos y filtros deben consultarse en cada archivo PHP, que es la fuente de verdad del contrato actual.

## Seguimiento publico

```http
GET /seguimiento.php?codigo=<codigo_de_seguimiento>&ferreteria=<slug>
```

Devuelve el estado publico, la linea de tiempo y, cuando existe, el diagnostico, los repuestos, el total, el abono y el estado de la cotizacion.

El código conserva su prefijo y formato consecutivo; cada ferretería mantiene
su propio contador. Si el mismo código existe en varias cuentas, consultar sin
`ferreteria` devuelve un error de ambigüedad y el cliente debe usar el enlace
completo que recibió.
