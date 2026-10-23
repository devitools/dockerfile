FROM webdevops/php-apache:7.4@sha256:2f959841830b22ab875c909b023fdcb87de32210cb6d1d6f032a2f3ab7514ed2 AS upstream

FROM upstream AS builder

ARG EXPECTED_PHP_VERSION=7.4.33
ARG PHP_SOURCE_SHA256=924846abf93bc613815c55dd3f5809377813ac62a9ec4eb3778675b82a27b927
ARG SURY_SOURCE_URL=https://packages.sury.org/php/pool/main/p/php7.4/php7.4_7.4.33-31%2B0~20261021.121%2Bdebian12~1.gbpe9c428.debian.tar.xz
ARG SURY_SOURCE_SHA256=4747b79a87b89a2591497704df4b80e68c7e78b64fbf23c205dca331ebf83496
ARG BUILD_JOBS=2

COPY .scripts/build-php.sh .scripts/apply-patches.sh .scripts/patches.list /tmp/build/
RUN bash /tmp/build/build-php.sh

FROM upstream AS php-apache

COPY --from=builder /patched/usr/local/ /usr/local/
COPY --from=builder /tmp/php-patched.tar.xz /usr/src/php.tar.xz
COPY --from=builder /security/ /usr/local/share/php-security/
COPY .scripts/verify.php /usr/local/share/php-security/verify.php

RUN rm -f /usr/src/php.tar.xz.asc \
    && printf 'session.upload_progress.enabled=0\n' > /usr/local/etc/php/conf.d/zz-security.ini \
    && php /usr/local/share/php-security/verify.php \
    && php-fpm -t

LABEL org.opencontainers.image.title="PHP 7.4 php-apache with Sury security backports" \
      org.opencontainers.image.source="https://github.com/devitools/dockerfile" \
      devitools.php.security-fixes="CVE-2026-109618,CVE-2026-109619" \
      devitools.php.patch-source="php7.4_7.4.33-31+0~20261021.121+debian12~1.gbpe9c428.debian.tar.xz"
