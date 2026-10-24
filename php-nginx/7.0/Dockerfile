FROM webdevops/php-nginx:7.0@sha256:3a6e0c7032dc596d0d179dea9959fb82e035e0a5abf01c09b60ac4d3f8431601 AS upstream

FROM upstream AS builder

ARG EXPECTED_PHP_VERSION=7.0.33
ARG PHP_SOURCE_SHA256=ab8c5be6e32b1f8d032909dedaaaa4bbb1a209e519abb01a52ce3914f9a13d96
ARG SURY_SOURCE_URL=https://packages.sury.org/php/pool/main/p/php7.0/php7.0_7.0.33-93%2B0~20261022.119%2Bdebian12~1.gbp952195.debian.tar.xz
ARG SURY_SOURCE_SHA256=926386e4c78a8f8b781bcdad61e82b269ad19936d8f30d98b9e3f6541136c25e
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

LABEL org.opencontainers.image.title="PHP 7.0 php-nginx with Sury security backports" \
      org.opencontainers.image.source="https://github.com/devitools/dockerfile" \
      devitools.php.security-fixes="CVE-2026-109618,CVE-2026-109619" \
      devitools.php.patch-source="php7.0_7.0.33-93+0~20261022.119+debian12~1.gbp952195.debian.tar.xz"
