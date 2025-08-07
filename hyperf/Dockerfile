FROM php:8.3-cli-alpine

ARG CONTEXT
ARG TIMEZONE
ARG APP_TARGET="liv"

ENV TIMEZONE=${TIMEZONE:-"UTC"} \
    STDOUT_LOG_LEVEL=alert,critical,emergency,error,warning \
    SCAN_CACHEABLE=(true)

COPY ${CONTEXT:-""}/rootfs /

RUN apk update && \
    apk upgrade --available && \
    apk add --no-cache bash curl git unzip && \
    mkdir -p /opt/www

COPY .scripts /devitools/.scripts

WORKDIR /opt/www

SHELL ["/bin/ash", "-o", "pipefail", "-c"]

RUN apk add --no-cache \
        php83-bcmath \
        php83-ctype \
        php83-curl \
        php83-dom \
        php83-fileinfo \
        php83-fpm \
        php83-gd \
        php83-iconv \
        php83-intl \
        php83-mbstring \
        php83-opcache \
        php83-openssl \
        php83-pcntl \
        php83-pdo \
        php83-pdo_mysql \
        php83-pecl-decimal \
        php83-pecl-ds \
        php83-pecl-mcrypt \
        php83-pecl-mongodb \
        php83-pecl-rdkafka \
        php83-pecl-redis \
        php83-pecl-swoole \
        php83-phar \
        php83-posix \
        php83-simplexml \
        php83-sodium \
        php83-tokenizer \
        php83-xml \
        php83-xmlreader \
        php83-xmlwriter \
        php83-zip \
        && mv /etc/php/php.ini /etc/php83/conf.d/zzz_0_devitools_php_dev.ini \
        && mv /etc/php/php-fpm.conf /etc/php83/php-fpm.d/zphp.conf

COPY --from=composer/composer:2.8.5-bin /composer /usr/local/bin/composer

RUN set -ex \
    && if [ "$APP_TARGET" = "dev" ]; then \
        bash /devitools/.scripts/setup-dev.sh; \
    fi \
    # ---------- apply settings ------- \
    && bash /devitools/.scripts/setup.sh "$TIMEZONE" \
    # ---------- clear works ---------- \
    && rm -rf /var/cache/apk/* /tmp/* /usr/share/man \
    && echo -e "\033[42;37m Build Completed :).\033[0m\n"

EXPOSE 9501

ENTRYPOINT [ "php", "/opt/www/bin/hyperf.php" ]

CMD [ "start" ]
