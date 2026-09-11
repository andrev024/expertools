# Decisiones tecnicas

## Backend sin framework

PHP 8.2 sin framework mantiene pequeno el despliegue y hace explicito el flujo HTTP, la autenticacion y el acceso PDO a MySQL. La logica de negocio compartida vive en `backend/src/`.

## Maquina de estados

Las transiciones se centralizan en `MaquinaEstados` para evitar que cada endpoint implemente reglas distintas. El administrador dispone de un bypass explicito para correcciones operativas excepcionales.

## Servicios administrados

La produccion usa Render para la API, Vercel para el frontend y Aiven para MySQL. Esta combinacion reduce el mantenimiento de servidores para un sistema de trafico bajo y permite despliegues automaticos desde Git.

## Docker

Docker Compose reproduce localmente la relacion entre frontend, backend y base de datos. El volumen de MySQL conserva los datos entre reinicios; los scripts SQL de inicializacion solo se ejecutan al crear una base vacia.

## Seguridad operativa

JWT protege las operaciones internas y el seguimiento publico se limita a la informacion necesaria para el cliente. Los secretos reales deben configurarse como variables de entorno en cada plataforma y no deben quedar escritos en el repositorio.
