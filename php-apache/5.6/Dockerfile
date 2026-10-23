FROM webdevops/php-apache:5.6@sha256:c6d88a33543f3b6360966caf9a8214d03548146dc0aae1774104568c4c0d683b AS upstream

FROM upstream AS builder

ARG EXPECTED_PHP_VERSION=5.6.40
ARG PHP_SOURCE_SHA256=1369a51eee3995d7fbd1c5342e5cc917760e276d561595b6052b21ace2656d1c
ARG SURY_SOURCE_URL=https://packages.sury.org/php/pool/main/p/php5.6/php5.6_5.6.40-105%2B0~20261022.135%2Bdebian12~1.gbp37a17e.debian.tar.xz
ARG SURY_SOURCE_SHA256=9b87b75b08921b559888381ad0cc9a7be64f67c3e246413dd1f0327c2651afff
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

LABEL org.opencontainers.image.title="PHP 5.6 php-apache with Sury security backports" \
      org.opencontainers.image.source="https://github.com/devitools/dockerfile" \
      devitools.php.security-fixes="CVE-2026-109618,CVE-2026-109619" \
      devitools.php.patch-source="php5.6_5.6.40-105+0~20261022.135+debian12~1.gbp37a17e.debian.tar.xz"
