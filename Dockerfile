# this is the docker file for the laravel project

FROM php:8.1-fpm

# Arguments defined in docker-compose.yml
ARG user
ARG uid

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Set working directory
WORKDIR /var/www

USER $user


# this is the docker file for native php project with httpd without laravel

FROM httpd:2.4

# Copy apache vhost file to proxy php requests to php-fpm container
COPY ./docker/apache/vhost.conf /usr/local/apache2/conf/vhost.conf

# Enable rewrite
RUN sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/g' /usr/local/apache2/conf/httpd.conf

# Enable vhost
RUN sed -i 's/#Include conf\/vhost.conf/Include conf\/vhost.conf/g' /usr/local/apache2/conf/httpd.conf

# Copy source code
COPY . /var/www/html

# Change current user to www
