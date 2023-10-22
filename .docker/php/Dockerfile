# Define arguments
ARG PHP_VERSION=8.1
ARG CADDY_VERSION=2

# Composer image
FROM composer:2 AS composer

# PHP image
FROM php:${PHP_VERSION}-fpm-alpine AS app_php

# Copy composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Set environment variables
ENV PHPGROUP=symfony
ENV PHPUSER=symfony

# Create user and modify configurations
RUN adduser -g ${PHPGROUP} -s /bin/sh -D ${PHPUSER} && \
    sed -i "s/user = www-data/user = ${PHPUSER}/g" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/group = www-data/group = ${PHPGROUP}/g" /usr/local/etc/php-fpm.d/www.conf

# Switch to symfony user
USER ${PHPUSER}

# Create public directory as symfony user
RUN mkdir -p /var/www/html/public

# Switch back to root for installations and configurations that require admin permissions
USER root

# Install PHP extensions
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/
RUN install-php-extensions pdo pdo_mysql intl zip apcu opcache

RUN apk add --no-cache autoconf g++ linux-headers make \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug

RUN echo 'xdebug.remote_enable = ${XDEBUG_ENABLED}' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo 'xdebug.client_host = host.docker.internal' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \


# Install dependencies, tools, vim, and nano
RUN apk update && \
    apk add --no-cache acl fcgi file gettext git bash sudo vim nano && \
    rm -rf /var/cache/apk/*

COPY php.ini /usr/local/etc/php/

# Config XDEBUG
COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# Set default command
CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]