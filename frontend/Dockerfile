# ETAPA 1: "build" -- usa Node para instalar dependencias y compilar React
FROM node:20-alpine AS build

WORKDIR /app

# Igual que con Composer: copiamos primero solo lo necesario para instalar
# dependencias, para aprovechar el cache de capas de Docker.
COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build
# Este comando genera la carpeta /app/dist con HTML/CSS/JS ya compilados y optimizados

# ETAPA 2: "serve" -- una imagen nueva, limpia, solo con Nginx.
# Todo lo de Node (node_modules, codigo fuente) se queda en la etapa 1
# y NUNCA llega a la imagen final -- por eso es mucho mas liviana.
FROM nginx:alpine

# Copiamos SOLO el resultado compilado de la etapa anterior
COPY --from=build /app/dist /usr/share/nginx/html

# Configuracion personalizada de Nginx (necesaria para que React Router funcione)
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
