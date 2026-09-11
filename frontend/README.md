# React + Vite

This template provides a minimal setup to get React working in Vite with HMR and some ESLint rules.

Currently, two official plugins are available:

## Expertools - frontend

Aplicacion React para la gestion de ordenes de reparacion y el seguimiento publico de articulos.

## Desarrollo local

Desde esta carpeta:

```bash
npm install
npm run dev
```

Vite inicia el frontend en `http://localhost:5173`. Para trabajar con el entorno completo, se recomienda levantar Docker Compose desde la raiz del proyecto; en ese caso el frontend servido por Nginx queda disponible en `http://localhost:5174`.

## Comandos

```bash
npm run dev      # servidor de desarrollo con hot reload
npm run build    # compilacion de produccion
npm run lint     # validacion ESLint
npm run preview  # servir la compilacion localmente
```

## Estructura principal

- `src/App.jsx`: rutas y composicion principal de la aplicacion.
- `src/components/`: paneles y componentes reutilizables.
- `src/context/`: estado compartido y autenticacion.
- `src/api.js`: comunicacion con la API PHP.
- `src/utils/`: utilidades de seguimiento y WhatsApp.

La documentacion general del sistema esta en el [README principal](../README.md).
