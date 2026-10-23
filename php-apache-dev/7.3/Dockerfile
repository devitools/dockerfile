FROM webdevops/php-apache-dev:7.3@sha256:d3e8d681cfdb0c1961fd8802be9c8385296583e2565c52bde199a436e7555493 AS upstream

FROM upstream AS builder

ARG EXPECTED_PHP_VERSION=7.3.33
ARG PHP_SOURCE_SHA256=166eaccde933381da9516a2b70ad0f447d7cec4b603d07b9a916032b215b90cc
ARG SURY_SOURCE_URL=https://packages.sury.org/php/pool/main/p/php7.3/php7.3_7.3.33-35%2B0~20261021.144%2Bdebian12~1.gbpecf76f.debian.tar.xz
ARG SURY_SOURCE_SHA256=6708d986af131aa0e0c7ecb65a47babacf2918d43a3d94d31341f64a734aa815
ARG BUILD_JOBS=2

COPY .scripts/build-php.sh .scripts/apply-patches.sh .scripts/patches.list /tmp/build/
RUN bash /tmp/build/build-php.sh

FROM upstream AS php-apache-dev

COPY --from=builder /patched/usr/local/ /usr/local/
COPY --from=builder /tmp/php-patched.tar.xz /usr/src/php.tar.xz
COPY --from=builder /security/ /usr/local/share/php-security/
COPY .scripts/verify.php /usr/local/share/php-security/verify.php

RUN rm -f /usr/src/php.tar.xz.asc \
    && printf 'session.upload_progress.enabled=0\n' > /usr/local/etc/php/conf.d/zz-security.ini \
    && php /usr/local/share/php-security/verify.php \
    && php-fpm -t

LABEL org.opencontainers.image.title="PHP 7.3 php-apache-dev with Sury security backports" \
      org.opencontainers.image.source="https://github.com/devitools/dockerfile" \
      devitools.php.security-fixes="CVE-2026-109618,CVE-2026-109619" \
      devitools.php.patch-source="php7.3_7.3.33-35+0~20261021.144+debian12~1.gbpecf76f.debian.tar.xz"
