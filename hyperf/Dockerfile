FROM alpine:3.20

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

SHELL ["/bin/ash", "-o", "pipefail", "-c"]

RUN apk add --no-cache \
        php83-bcmath=8.3.15-r0 \
        php83-ctype=8.3.15-r0 \
        php83-curl=8.3.15-r0 \
        php83-dom=8.3.15-r0 \
        php83-fileinfo=8.3.15-r0 \
        php83-fpm=8.3.15-r0 \
        php83-gd=8.3.15-r0 \
        php83-iconv=8.3.15-r0 \
        php83-intl=8.3.15-r0 \
        php83-mbstring=8.3.15-r0 \
        php83-opcache=8.3.15-r0 \
        php83-openssl=8.3.15-r0 \
        php83-pcntl=8.3.15-r0 \
        php83-pdo=8.3.15-r0 \
        php83-pdo_mysql=8.3.15-r0 \
        php83-pecl-decimal=1.5.0-r1 \
        php83-pecl-ds=1.5.0-r0 \
        php83-pecl-mcrypt=1.0.7-r0 \
        php83-pecl-mongodb=1.19.1-r0 \
        php83-pecl-rdkafka=6.0.5-r0 \
        php83-pecl-redis=6.1.0-r0 \
        php83-pecl-swoole=5.1.6-r0 \
        php83-phar=8.3.15-r0 \
        php83-posix=8.3.15-r0 \
        php83-simplexml=8.3.15-r0 \
        php83-sodium=8.3.15-r0 \
        php83-tokenizer=8.3.15-r0 \
        php83-xml=8.3.15-r0 \
        php83-xmlreader=8.3.15-r0 \
        php83-xmlwriter=8.3.15-r0 \
        php83-zip=8.3.15-r0 \
    && ln -sf /usr/bin/php83 /usr/bin/php \
    && mv /etc/php/php.ini /etc/php83/conf.d/zzz_1_php.ini \
    && mv /etc/php/php-fpm.conf /etc/php83/php-fpm.d/zphp.conf

COPY --from=composer/composer:2.8.5-bin /composer /usr/local/bin/composer

COPY .scripts /devitools/.scripts

# update
RUN set -ex \
    # ---------- apply settings -------\
    && bash /devitools/.scripts/setup.sh "$TIMEZONE" \
    && bash /devitools/.scripts/setup-dev.sh "$APP_TARGET" \
    # ---------- clear works ----------\
    && rm -rf /var/cache/apk/* /tmp/* /usr/share/man

WORKDIR /opt/www

EXPOSE 9501

ENTRYPOINT [ "php", "/opt/www/bin/hyperf.php" ]

CMD [ "start" ]
