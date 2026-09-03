# Imagen base: PHP 8.2 con el servidor Apache ya incluido
FROM php:8.2-apache

# Instala las extensiones de PHP que tu app necesita: PDO para MySQL.
RUN docker-php-ext-install pdo pdo_mysql

# La extension zip necesita la libreria del sistema libzip-dev primero.
# Sin esto, Composer no puede descomprimir los paquetes que descarga
# (el mismo problema que tuviste en tu XAMPP local, aqui dentro de la imagen).
RUN apt-get update && apt-get install -y libzip-dev unzip \
    && docker-php-ext-install zip \
    && rm -rf /var/lib/apt/lists/*

# Instala Composer dentro de la imagen (copiando el binario oficial)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Carpeta de trabajo dentro del contenedor
WORKDIR /var/www/html

# Copia primero solo composer.json (aprovecha el "cache" de Docker:
# si no cambian las dependencias, no las vuelve a instalar en cada build)
COPY composer.json ./
RUN composer install --no-interaction --no-dev --optimize-autoloader

# Ahora copia el resto del codigo de la aplicacion
COPY . .

# Apache sirve desde /var/www/html/public en vez de /var/www/html directamente
# (asi el navegador nunca puede ver tu carpeta src/ ni tu .env)
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# Habilita mod_rewrite (util mas adelante para rutas mas limpias)
RUN a2enmod rewrite

EXPOSE 80
