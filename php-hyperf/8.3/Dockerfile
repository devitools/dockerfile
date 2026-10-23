FROM alpine:3.21 AS hyperf

ARG CONTEXT
ARG TIMEZONE
ARG APP_TARGET="liv"

ENV TIMEZONE=${TIMEZONE:-"UTC"} \
    STDOUT_LOG_LEVEL=alert,critical,emergency,error,warning \
    SCAN_CACHEABLE=(true)

COPY ${CONTEXT:-""}/rootfs /

RUN apk update && \
    apk upgrade --available && \
    apk add --no-cache bash curl git tzdata unzip && \
    mkdir -p /opt/www

SHELL ["/bin/ash", "-o", "pipefail", "-c"]

RUN apk add --no-cache \
        php83-bcmath=8.3.36-r0 \
        php83-ctype=8.3.36-r0 \
        php83-curl=8.3.36-r0 \
        php83-dom=8.3.36-r0 \
        php83-fileinfo=8.3.36-r0 \
        php83-fpm=8.3.36-r0 \
        php83-gd=8.3.36-r0 \
        php83-iconv=8.3.36-r0 \
        php83-intl=8.3.36-r0 \
        php83-mbstring=8.3.36-r0 \
        php83-opcache=8.3.36-r0 \
        php83-openssl=8.3.36-r0 \
        php83-pcntl=8.3.36-r0 \
        php83-pdo=8.3.36-r0 \
        php83-pdo_mysql=8.3.36-r0 \
        php83-pecl-brotli=0.15.2-r0 \
        php83-pecl-decimal=1.5.0-r1 \
        php83-pecl-ds=1.5.0-r0 \
        php83-pecl-mcrypt=1.0.7-r0 \
        php83-pecl-mongodb=1.20.1-r0 \
        php83-pecl-rdkafka=6.0.5-r0 \
        php83-pecl-redis=6.2.0-r0 \
        php83-phar=8.3.36-r0 \
        php83-posix=8.3.36-r0 \
        php83-simplexml=8.3.36-r0 \
        php83-sodium=8.3.36-r0 \
        php83-tokenizer=8.3.36-r0 \
        php83-xml=8.3.36-r0 \
        php83-xmlreader=8.3.36-r0 \
        php83-xmlwriter=8.3.36-r0 \
        php83-zip=8.3.36-r0 \
    && ln -sf /usr/bin/php83 /usr/bin/php \
    && mv /etc/php/php.ini /etc/php83/conf.d/zzz_1_php.ini \
    && mv /etc/php/php-fpm.conf /etc/php83/php-fpm.d/zphp.conf

RUN apk add --no-cache libstdc++ c-ares libpq sqlite-libs brotli-libs \
    && apk add --no-cache --virtual .swoole-build \
        autoconf g++ make linux-headers php83-dev=8.3.36-r0 \
        openssl-dev curl-dev c-ares-dev postgresql-dev sqlite-dev brotli-dev \
    && curl -fsSL https://pecl.php.net/get/swoole-5.1.8.tgz -o /tmp/swoole.tgz \
    && echo 'c365ccd37b1804527064325a0d2641d4bc33fda23c5b4660dd840ac24f333aa8  /tmp/swoole.tgz' | sha256sum -c - \
    && tar -xzf /tmp/swoole.tgz -C /tmp \
    && cd /tmp/swoole-5.1.8 \
    && phpize83 \
    && ./configure --with-php-config=/usr/bin/php-config83 \
        --enable-openssl --enable-sockets --enable-swoole-curl \
        --enable-cares --enable-brotli --enable-mysqlnd \
        --enable-swoole-pgsql --enable-swoole-sqlite \
    && make -j2 \
    && make install \
    && echo 'extension=swoole.so' > /etc/php83/conf.d/50_swoole.ini \
    && apk del .swoole-build \
    && rm -rf /tmp/swoole* \
    && php --ri swoole

COPY --from=composer/composer:2.8.5-bin /composer /usr/local/bin/composer

COPY .scripts /devitools/.scripts

RUN set -ex \
    && bash /devitools/.scripts/setup.sh "$TIMEZONE" \
    && bash /devitools/.scripts/setup-dev.sh "$APP_TARGET" \
    && rm -rf /var/cache/apk/* /tmp/* /usr/share/man

WORKDIR /opt/www
EXPOSE 9501
ENTRYPOINT ["php", "/opt/www/bin/hyperf.php"]
CMD ["start"]

# --- Variant: with OTEL Collector + pgbouncer + supervisor ---
FROM hyperf AS hyperf-otel

ARG COLLECTOR=debug
ARG OTEL_COLLECTOR_VERSION=0.121.0

RUN apk add --no-cache --upgrade expat \
    && apk add --no-cache supervisor wget pgbouncer \
    && OTEL_BASE_URL="https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v${OTEL_COLLECTOR_VERSION}" \
    && OTEL_ASSET="otelcol-contrib_${OTEL_COLLECTOR_VERSION}_linux_amd64.tar.gz" \
    && cd /tmp \
    && wget -q "${OTEL_BASE_URL}/${OTEL_ASSET}" -O "${OTEL_ASSET}" \
    && wget -q "${OTEL_BASE_URL}/opentelemetry-collector-releases_otelcol-contrib_checksums.txt" -O checksums.txt \
    && grep " ${OTEL_ASSET}$" checksums.txt | sha256sum -c - \
    && tar -xzf "${OTEL_ASSET}" -C /usr/local/bin otelcol-contrib \
    && rm "${OTEL_ASSET}" checksums.txt \
    && chmod +x /usr/local/bin/otelcol-contrib \
    && mkdir -p /etc/pgbouncer /var/log/pgbouncer /var/run/pgbouncer /etc/supervisor.d /var/run/supervisor

COPY otel/collectors/${COLLECTOR}.yaml /etc/otel-collector-config.yaml
COPY otel/supervisord.conf /etc/supervisord.conf
COPY otel/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD []
