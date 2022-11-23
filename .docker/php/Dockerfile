ARG PHP_VERSION=8.1
ARG CADDY_VERSION=2

FROM composer:2 AS composer
FROM php:${PHP_VERSION}-fpm-alpine AS app_php
COPY --from=composer /usr/bin/composer /usr/bin/composer

ENV PHPGROUP=symfony
ENV PHPUSER=symfony

RUN adduser -g ${PHPGROUP} -s /bin/sh -D ${PHPUSER}

RUN sed -i "s/user = www-data/user = ${PHPUSER}/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = ${PHPGROUP}/g" /usr/local/etc/php-fpm.d/www.conf

RUN mkdir -p /var/www/html/public

# php extensions installer: https://github.com/mlocati/docker-php-extension-installer
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

RUN apk update && apk add bash sudo

RUN docker-php-ext-install pdo pdo_mysql

# persistent / runtime deps
RUN apk add --no-cache \
		acl \
		fcgi \
		file \
		gettext \
		git \
	;

RUN set -eux; \
    install-php-extensions \
    	intl \
    	zip \
    	apcu \
		opcache \
    ;

RUN curl -sS https://get.symfony.com/cli/installer | bash

RUN sudo apk add --no-cache bash
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.alpine.sh' | sudo -E bash
RUN sudo apk add symfony-cli

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]