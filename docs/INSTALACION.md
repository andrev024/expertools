# Instalacion y configuracion

## Requisitos

- Docker Desktop con Docker Compose
- Git
- PHP 8.2 y Composer, solo si se ejecutan pruebas fuera de Docker
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

La base de datos se inicializa con `database/schema.sql` y `database/seed.sql` la primera vez que se crea el volumen.

## Configuracion del backend sin Docker

Crear `backend/.env` con valores locales:

```dotenv
DB_HOST=localhost
DB_NAME=taller_tracker
DB_USER=root
DB_PASS=
JWT_SECRET=generar-una-clave-larga-y-privada
JWT_EXPIRATION_SECONDS=28800
```

No reutilizar la clave incluida en `docker-compose.yml` para un entorno real. Las credenciales y secretos no deben subirse al repositorio.

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
