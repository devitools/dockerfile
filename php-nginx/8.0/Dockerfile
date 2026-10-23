FROM webdevops/php-nginx:8.0@sha256:3377d9a7cd7f4da0a7cd073ff0208b212bc5c73e2a112a7e983b353d30295635 AS upstream

FROM upstream AS builder

ARG EXPECTED_PHP_VERSION=8.0.30
ARG PHP_SOURCE_SHA256=216ab305737a5d392107112d618a755dc5df42058226f1670e9db90e77d777d9
ARG SURY_SOURCE_URL=https://packages.sury.org/php/pool/main/p/php8.0/php8.0_8.0.30-25%2B0~20261021.88%2Bdebian12~1.gbpabebea.debian.tar.xz
ARG SURY_SOURCE_SHA256=8dd2d897829859df423919744fa4db2a4a61c027ffa6afdef01d276262f5df6e
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

LABEL org.opencontainers.image.title="PHP 8.0 php-nginx with Sury security backports" \
      org.opencontainers.image.source="https://github.com/devitools/dockerfile" \
      devitools.php.security-fixes="CVE-2026-109618,CVE-2026-109619" \
      devitools.php.patch-source="php8.0_8.0.30-25+0~20261021.88+debian12~1.gbpabebea.debian.tar.xz"
