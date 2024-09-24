FROM php:8.3-cli-alpine

LABEL maintainer="Mohamad Momeni"

ENV TZ=Asia/Tehran

RUN mkdir -p /var/www

WORKDIR /var/www

RUN apk add --no-cache --update supervisor nano tzdata openssl-dev libzip-dev zlib-dev libpng-dev freetype-dev libjpeg-turbo-dev $PHPIZE_DEPS && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install pdo pdo_mysql zip gd pcntl && \
    pecl install redis && docker-php-ext-enable redis && \
    pecl install mongodb && docker-php-ext-enable mongodb && \
    pecl install swoole && docker-php-ext-enable swoole
    
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

Add ./supervisor.ini /etc/supervisor.d/custom.ini
ADD ./php.ini /usr/local/etc/php/conf.d/custom.ini

CMD ["sh", "-c", "supervisord -c /var/www/supervisor.conf"]
