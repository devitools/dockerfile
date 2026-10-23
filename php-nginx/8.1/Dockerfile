FROM webdevops/php-nginx:8.1@sha256:d9ee3ec3b8795b443581c5f3f724c6b91d3a7db42775d4d5286ec9c5884a9f65 AS upstream

FROM upstream AS builder

ARG EXPECTED_PHP_VERSION=8.1.34
ARG PHP_SOURCE_SHA256=ffa9e0982e82eeaea848f57687b425ed173aa278fe563001310ae2638db5c251
ARG SURY_SOURCE_URL=https://packages.sury.org/php/pool/main/p/php8.1/php8.1_8.1.34-9%2B0~20261021.82%2Bdebian12~1.gbp4e430a.debian.tar.xz
ARG SURY_SOURCE_SHA256=03a83aeb5b1912d7b427e331c1287860d31a3a6c8b49ff40ac83df371283979c
ARG BUILD_JOBS=2

COPY .scripts/build-php.sh .scripts/apply-patches.sh .scripts/patches.list /tmp/build/
RUN bash /tmp/build/build-php.sh

FROM upstream AS php-nginx

COPY --from=builder /patched/usr/local/ /usr/local/
COPY --from=builder /tmp/php-patched.tar.xz /usr/src/php.tar.xz
COPY --from=builder /security/ /usr/local/share/php-security/
COPY .scripts/verify.php /usr/local/share/php-security/verify.php

RUN rm -f /usr/src/php.tar.xz.asc \
    && printf 'session.upload_progress.enabled=0\n' > /usr/local/etc/php/conf.d/zz-security.ini \
    && php /usr/local/share/php-security/verify.php \
    && php-fpm -t

LABEL org.opencontainers.image.title="PHP 8.1 php-nginx with Sury security backports" \
      org.opencontainers.image.source="https://github.com/devitools/dockerfile" \
      devitools.php.security-fixes="CVE-2026-109618,CVE-2026-109619" \
      devitools.php.patch-source="php8.1_8.1.34-9+0~20261021.82+debian12~1.gbp4e430a.debian.tar.xz"
