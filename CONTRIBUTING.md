# Guia de contribucion

## Flujo de trabajo

1. Crear una rama descriptiva desde `main`.
2. Mantener cada cambio enfocado en una funcionalidad o correccion.
3. Ejecutar las pruebas y validaciones antes de abrir el Pull Request.
4. Describir el problema, la solucion y cualquier migracion necesaria.

## Validaciones locales

```bash
cd backend
vendor/bin/phpunit

cd ../frontend
npm run lint
npm run build
```

Los cambios de base de datos deben incluir el SQL correspondiente en `database/` y explicar si requieren reinicializar una instalacion existente. No incluir secretos, archivos `.env`, credenciales ni datos reales de clientes.
