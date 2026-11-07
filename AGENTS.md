# Instrucciones para agentes

Antes de cambiar una parte del sistema, consulta la documentación pertinente: [instalación](docs/INSTALACION.md), [API](docs/API.md), [flujo de negocio](docs/FLUJO_NEGOCIO.md), [roles y permisos](docs/ROLES_Y_PERMISOS.md), [decisiones técnicas](docs/DECISIONES_TECNICAS.md) y [contribución](CONTRIBUTING.md). El código y la configuración actuales son la fuente de verdad si un documento está desactualizado.

## Arquitectura y límites

- Backend PHP sin framework: los endpoints HTTP están en `backend/public/`; la lógica reutilizable y la infraestructura van en `backend/src/`. Mantén las reglas de negocio fuera de los endpoints cuando ya exista una abstracción para ellas.
- Frontend React/Vite: `frontend/src/App.jsx` compone vistas y rutas, `components/` contiene la UI, `context/` el estado compartido y `frontend/src/api.js` centraliza las llamadas HTTP.
- `apiFetch` agrega el JWT, interpreta JSON y lanza errores de API. `API_BASE` apunta a producción; Vite no tiene proxy para redirigir llamadas al backend local.
- Conserva los nombres de estados y campos existentes. Las transiciones y permisos son controles separados: revisa `MaquinaEstados` y la autorización del endpoint al cambiar este flujo.

## Convenciones y precauciones

- Mantén la identidad real de Expertools en cambios visuales: reutiliza el logo existente, el turquesa `#4C9E9E` y el blanco, y aplica los cambios de forma consistente en las vistas afectadas. Evita sustituir la marca por contenido genérico.
- Los estilos activos están en `frontend/src/index.css`, importado desde `main.jsx`; `App.css` no está importado. Los botones neutros deben usar `button-quiet` por la regla global de botones.
- Reutiliza `frontend/src/utils/whatsapp.js` para enlaces, teléfonos y mensajes. Si una acción abre WhatsApp tras una llamada asíncrona, crea la ventana sincrónicamente antes del `await` para evitar que el navegador bloquee el popup.
- Las cotizaciones actualmente no calculan IVA; el campo de base de datos se conserva por compatibilidad. No lo reincorpores sin cambiar explícitamente la regla de negocio.
- Usa consultas preparadas y transacciones para escrituras de varios pasos. Los tests de PHPUnit cubren lógica aislada, no flujos HTTP respaldados por base de datos.
- `docker-compose.yml` monta `database/schema.sql` y `database/seed.sql`, pero esos archivos no están presentes en este checkout. Verifica los archivos de inicialización y el volumen persistente antes de diagnosticar un fallo de arranque o cambios de esquema.
- Para frontend, `frontend/package.json` define React 19; no te guíes por la versión antigua mencionada en el README raíz.

## Validación

Ejecuta las comprobaciones pertinentes al cambio antes de terminar:

```bash
cd backend
vendor/bin/phpunit

cd ../frontend
npm run lint
npm run build
```

Para levantar el stack local se requiere Docker Desktop: `docker compose up --build`. Para instrucciones completas, consulta [instalación](docs/INSTALACION.md).