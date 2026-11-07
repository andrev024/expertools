# Decisiones tecnicas

## Backend sin framework

PHP 8.2 sin framework mantiene pequeno el despliegue y hace explicito el flujo HTTP, la autenticacion y el acceso PDO. La conexión admite MySQL y PostgreSQL mediante `DB_DRIVER`; la producción permanece en MySQL hasta completar y validar la migración de datos. La lógica de negocio compartida vive en `backend/src/`.

## Maquina de estados

Las transiciones se centralizan en `MaquinaEstados` para evitar que cada endpoint implemente reglas distintas. El administrador dispone de un bypass explicito para correcciones operativas excepcionales.

## Servicios administrados

La producción usa Render para la API, Vercel para el frontend y Aiven para la base de datos. La instancia MySQL existente debe mantenerse activa hasta validar PostgreSQL, el respaldo y el cambio de conexión en producción.

## Multiempresa

La base de datos compartida contiene una fila de `ferreteria` por cuenta. Los
usuarios, clientes y órdenes tienen una referencia directa a su ferretería;
artículos y demás datos asociados pertenecen a la ferretería del cliente u
orden al que están ligados. La API toma la ferretería del JWT validado y aplica
ese ámbito en lecturas y escrituras.

Cada ferretería conserva su prefijo y tiene su propio consecutivo. Los códigos
pueden repetirse entre ferreterías; el seguimiento público los desambigua con
un `slug` en el enlace.

La migración `database/migration_v6_multiempresa.sql` asigna todos los datos
existentes a la cuenta inicial `Expertools`. Debe revisarse y probarse con un
respaldo antes de aplicarla manualmente; Terraform administra infraestructura,
no ejecuta migraciones de esquema.

`ferreteria.logo_key` contiene la clave de un logo PNG/JPEG en Cloudflare R2.
El bucket permanece privado; el backend limita las cargas, lecturas y
eliminaciones a usuarios autenticados de la ferretería correspondiente. Los
comprobantes PDF usan su nombre comercial, teléfono, dirección y logo. Los
secretos de R2 se configuran únicamente en Render.

## Docker

Docker Compose conserva MySQL para el entorno local actual. La imagen del backend incluye ambos controladores PDO; el motor se elige con `DB_DRIVER`. El volumen de MySQL conserva los datos entre reinicios; los scripts SQL de inicialización solo se ejecutan al crear una base vacía.

## Seguridad operativa

JWT protege las operaciones internas y el seguimiento publico se limita a la informacion necesaria para el cliente. Los secretos reales deben configurarse como variables de entorno en cada plataforma y no deben quedar escritos en el repositorio.
