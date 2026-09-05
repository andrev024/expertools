# Imagen base: PHP 8.2 con el servidor Apache ya incluido
FROM php:8.2-apache
 
# Instala las extensiones de PHP que tu app necesita: PDO para MySQL.
RUN docker-php-ext-install pdo pdo_mysql
 
# La extension zip necesita la libreria del sistema libzip-dev primero.
RUN apt-get update && apt-get install -y libzip-dev unzip \
    && docker-php-ext-install zip \
    && rm -rf /var/lib/apt/lists/*
 
# Instala Composer dentro de la imagen
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
 
WORKDIR /var/www/html
 
COPY composer.json ./
RUN composer install --no-interaction --no-dev --optimize-autoloader
 
COPY . .
 
# Apache sirve desde /var/www/html/public en vez de /var/www/html directamente
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf
 
# IMPORTANTE: ademas de cambiar el DocumentRoot, Apache necesita permiso
# EXPLICITO para servir archivos desde esa carpeta especifica. Sin este
# bloque, deniega el acceso con "Forbidden" aunque el archivo exista.
# NOTA DE SEGURIDAD: "Options" NO incluye "Indexes" a proposito -- eso
# evitaria que Apache liste el contenido de la carpeta si alguien entra
# a una URL sin archivo especifico (como la raiz "/"), lo cual expondria
# la estructura interna del proyecto a cualquier visitante.
RUN echo '<Directory /var/www/html/public/>\n\
    Options FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' >> /etc/apache2/apache2.conf
 
RUN a2enmod rewrite
 
EXPOSE 80
 