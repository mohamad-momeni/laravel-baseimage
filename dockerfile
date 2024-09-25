FROM composer:2 AS composer
FROM node:20-alpine AS node
FROM php:8.3-cli-alpine

LABEL maintainer="Mohamad Momeni"

ENV TZ=Asia/Tehran

RUN apk add --no-cache --update supervisor nano tzdata openssl-dev libzip-dev zlib-dev libpng-dev freetype-dev libjpeg-turbo-dev $PHPIZE_DEPS libstdc++ libgcc && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install pdo pdo_mysql zip gd pcntl && \
    pecl install redis && docker-php-ext-enable redis && \
    pecl install mongodb && docker-php-ext-enable mongodb && \
    pecl install swoole && docker-php-ext-enable swoole

COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /usr/local/include/node /usr/local/include/node
COPY --from=node /usr/local/bin/node /usr/local/bin/node
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm
RUN ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

COPY --from=composer /usr/bin/composer /usr/local/bin/composer

ADD ./bolt.so $(php-config --extension-dir)
RUN echo 'extension=bolt.so' > /usr/local/etc/php/conf.d/docker-php-ext-bolt.so