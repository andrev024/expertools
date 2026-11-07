# Instalacion y configuracion

## Requisitos

- Docker Desktop con Docker Compose
- Git
- PHP 8.2 con `pdo_mysql` o `pdo_pgsql` y Composer, solo si se ejecutan pruebas fuera de Docker
- Node.js y npm, solo si se desarrolla el frontend con Vite

## Ejecucion recomendada

Desde la raiz del repositorio:

```bash
docker compose up --build
```

Servicios disponibles:

| Servicio | URL o puerto |
|---|---|
| Frontend | `http://localhost:5174` |
| API | `http://localhost:8000` |
| MySQL desde el host | `localhost:3307` |
| MySQL dentro de Docker | `db:3306` |

El entorno local sigue usando MySQL. El backend también admite PostgreSQL
configurando `DB_DRIVER=pgsql`; la imagen Docker instala ambos controladores
PDO para permitir preparar y validar la migración sin reemplazar aún la base
actual.

La base de datos se inicializa con `database/schema.sql` y `database/seed.sql` la primera vez que se crea el volumen.

## Migración multiempresa

`database/migration_v6_multiempresa.sql` es una migración manual para una base
existente, no un script de inicialización de Docker ni parte de Terraform.
Antes de aplicarla en producción:

1. Genera y verifica un respaldo recuperable de Aiven.
2. Pruébala en una copia de la base y confirma que usuarios, clientes y
   órdenes quedan asociados a la ferretería inicial `Expertools`, y que el
   consecutivo se inicializa desde el mayor código existente más uno.
3. Asegura una ventana de mantenimiento: la migración incluye cambios DDL de
   MySQL y no es reversible con un simple `ROLLBACK`. Pausa temporalmente las
   escrituras y la API para evitar que la versión anterior cree usuarios o
   clientes mientras las nuevas columnas son obligatorias.
4. Aplica la migración una sola vez, valida las asociaciones y despliega el
   backend antes de reabrir el servicio.
5. Solicita a los usuarios que cierren sesión e inicien sesión de nuevo; los
   tokens anteriores no incluyen el identificador de ferretería.

No ejecutes esta migración desde Terraform ni desde el arranque de la API.

### Crear la cuenta y el primer administrador

Después de aplicar y verificar la migración multiempresa en la base destino,
se puede crear una cuenta vacía desde una terminal interactiva con acceso
seguro a esa base:

```bash
cd backend
php bin/crear_ferreteria.php
```

El comando pide el nombre comercial, `slug`, prefijo, nombre y correo del
primer administrador, y una contraseña que no se muestra al escribir. Revisa
el host y nombre de la base de datos que imprime; confirma solo escribiendo
`CREAR` si es el destino correcto. La creación de la ferretería y su
administrador ocurre en una sola transacción. El comando no importa datos ni
debe ejecutarse antes de la migración.

Los correos de usuario aún son únicos en todo el sistema: usa un correo que no
esté asignado a otra ferretería. Si se importará historial, no entregues las
credenciales ni operes esa cuenta hasta terminar la importación y actualizar
`siguiente_consecutivo` al máximo código histórico más uno. La cuenta nueva
empieza en 600; **no restaures su dump directamente** sobre las tablas
compartidas. El mapeo/importador se debe preparar al recibir su esquema real.

### Incorporar una ferretería con datos históricos

La migración anterior prepara solo la cuenta inicial. La base histórica de cada
nuevo negocio debe mapearse antes de importar: usuarios, clientes, artículos,
órdenes y sus relaciones. Como los IDs pueden coincidir entre bases distintas,
la importación debe asignar IDs nuevos y remapear las relaciones al nuevo
`ferreteria_id`; no se debe restaurar el dump de otro negocio directamente
sobre las tablas compartidas. Al terminar, se configura el `slug` exclusivo,
el prefijo que ya usa el negocio y el siguiente consecutivo a partir de sus
órdenes importadas. Este proceso requiere revisar el esquema de esa ferretería;
no es una tarea que Terraform pueda realizar.

Cuando se consiga una ferretería, antes de importar pide:

- Un volcado de **estructura solamente**, sin `INSERT`, credenciales ni datos
  personales. En MySQL se puede generar con `mysqldump --no-data`.
- Una lista de qué información se quiere conservar y qué estados usa su flujo.
- Ejemplos anonimizados del formato de sus códigos y el mayor consecutivo
  utilizado, junto con el prefijo que quiere mantener.
- Los nombres, correos y roles de las personas que necesitarán acceso; no
  solicites ni importes contraseñas en texto plano.

Con eso se define el mapeo de columnas y relaciones, se ensaya la importación
en una copia y se verifica el contador antes de entregar credenciales. El
comando de alta crea la ferretería y el primer administrador, pero no sustituye
ese importador específico.

## Configuracion del backend sin Docker

Crear `backend/.env` con valores locales:

```dotenv
DB_HOST=localhost
DB_DRIVER=mysql
DB_NAME=taller_tracker
DB_USER=root
DB_PASS=
JWT_SECRET=generar-una-clave-larga-y-privada
JWT_EXPIRATION_SECONDS=28800
```

No reutilizar la clave incluida en `docker-compose.yml` para un entorno real. Las credenciales y secretos no deben subirse al repositorio.

### Conexión a PostgreSQL de Aiven

Cuando la base PostgreSQL ya esté creada y tenga el esquema y los datos
migrados, configura en el servicio backend de Render las variables entregadas
por Aiven:

```dotenv
DB_DRIVER=pgsql
DB_HOST=host-de-aiven
DB_PORT=puerto-de-aiven
DB_NAME=nombre-de-base
DB_USER=usuario-de-aiven
DB_PASS=secreto-de-aiven
DB_SSL_MODE=require
```

Si Aiven proporciona un certificado CA y se monta en el contenedor, añade
`DB_SSL_CA_PATH` con su ruta y utiliza `DB_SSL_MODE=verify-full` para validar
también el hostname. No cambies la conexión de producción hasta que el
respaldo MySQL se haya restaurado y validado en PostgreSQL; conserva MySQL
intacto hasta verificar el login y las operaciones principales en producción.
La descarga de respaldo de PostgreSQL requiere `pg_dump`, incluido en la
imagen Docker del backend; valida que su versión cliente sea compatible con
la versión del servidor Aiven.

`database/schema_actual.sql` es una exportación de MySQL y
`database/migration_v6_multiempresa.sql` contiene DDL de MySQL. No los ejecutes
directamente en PostgreSQL. Mantén cualquier exportación con datos reales fuera
de Git y de canales públicos; prepara el esquema PostgreSQL desde una copia
controlada y valida el mapeo antes de migrar producción.

`database/schema_postgresql.sql` define la estructura PostgreSQL equivalente al
esquema multiempresa actual. Se aplica únicamente a una base PostgreSQL vacía;
no contiene datos y no migra registros. Ensaya primero la carga de datos en una
copia y verifica conteos y relaciones antes de cambiar el backend de producción.

Para importar el archivo descargado `database/schema_actual.sql` a PostgreSQL,
usa Docker para disponer del controlador PDO incluso si PHP local no tiene
`pdo_pgsql`. Desde la raíz del proyecto, construye y ejecuta la imagen:

```powershell
docker build -t expertools-backend-pg .\backend
docker run --rm -it --mount "type=bind,source=$($PWD.Path),target=/workspace" --workdir /workspace expertools-backend-pg php backend/bin/migrar_mysql_a_postgresql.php
```

El proceso lee el respaldo local, no se conecta a MySQL, y solicita el host,
puerto, base, usuario y contraseña de PostgreSQL de Aiven. La contraseña se
ingresa sin mostrarse. Usa SSL (`sslmode=require`); si tienes un certificado CA
montado en el contenedor, proporciona su ruta para activar `verify-full`. El
importador exige que el esquema destino contenga las diez tablas esperadas y
esté vacío, muestra solo conteos, requiere escribir `IMPORTAR DATOS` y revierte
toda la copia si falla alguna inserción o verificación. No modifica el archivo
de respaldo ni la base MySQL original.

## Configurar logos en Cloudflare R2

Los logos se guardan en un bucket **privado**; el navegador y Vercel nunca
reciben credenciales de R2 ni URLs públicas para los archivos. El backend los
sube y sirve después de validar el JWT y la ferretería.

1. Crea un bucket R2 privado para los logos.
2. Genera credenciales S3 de R2 con permisos de lectura, escritura y borrado
   únicamente para ese bucket.
3. Agrega estas variables en el entorno del servicio backend de Render:

   ```dotenv
   R2_ACCOUNT_ID=identificador_de_cuenta_cloudflare
   R2_ACCESS_KEY_ID=clave_de_acceso
   R2_SECRET_ACCESS_KEY=secreto_de_acceso
   R2_BUCKET_NAME=nombre_del_bucket
   ```

4. No pongas estas variables en Vercel, en el frontend ni en archivos versionados.
5. Entra al panel con un usuario de recepción o administrador y abre **Marca del
   negocio**. Actualiza los datos comerciales y sube un logo PNG/JPEG de hasta
   2 MB y 4096 × 4096 píxeles.

El Dockerfile permite archivos de hasta 3 MB a nivel PHP para que el límite de
aplicación de 2 MB no choque con los encabezados del formulario multipart. Si
Render se configura sin usar este Dockerfile, establece `upload_max_filesize`
en 3 MB o más y `post_max_size` en 4 MB o más.

Cloudflare R2 publica una cuota gratuita mensual para almacenamiento Standard
(actualmente 10 GB-mes, 1 millón de operaciones Clase A y 10 millones Clase B;
el egreso desde R2 no tiene costo). El uso que supere la cuota se factura según
las [tarifas vigentes de Cloudflare R2](https://developers.cloudflare.com/r2/pricing/).
Verifica los precios antes de producción.

## Pruebas y frontend

```bash
cd backend
composer install
vendor/bin/phpunit

cd ../frontend
npm install
npm run lint
npm run build
```

Para reinicializar la base de datos de prueba, detener los servicios y eliminar el volumen `db_data`. Esto borra los datos locales almacenados en Docker.
