FROM webdevops/php-apache:7.3@sha256:aec98f365a8f9e35ff354ac1c0893ba15141807557f40f31f02fea6ed540c43b AS upstream

FROM upstream AS builder

ARG SURY_SOURCE_VERSION=7.3.33-35+0~20261021.144+debian12~1.gbpecf76f
ARG SURY_SOURCE_SHA256=6708d986af131aa0e0c7ecb65a47babacf2918d43a3d94d31341f64a734aa815
ARG BUILD_JOBS=2

COPY .scripts/build-php.sh /tmp/build-php.sh
RUN bash /tmp/build-php.sh

RUN test "$(php-config --extension-dir)" = "$(/patched/usr/local/bin/php-config --extension-dir)" \
    && mkdir -p /tmp/patched-source/php \
    && tar -xJf /usr/src/php.tar.xz -C /tmp/patched-source/php --strip-components=1 \
    && cd /tmp/patched-source/php \
    && patch --batch --fuzz=0 -p1 < /security/0079-Introduce-max_multipart_body_parts-INI.patch \
    && patch --batch --fuzz=0 -p1 < /security/0139-Avoid-state-corruption-via-bailout.patch \
    && tar -cJf /tmp/php-patched.tar.xz -C /tmp/patched-source php

FROM upstream AS php-apache

COPY --from=builder /patched/usr/local/ /usr/local/
COPY --from=builder /tmp/php-patched.tar.xz /usr/src/php.tar.xz
COPY --from=builder /security/ /usr/local/share/php-security/
COPY .scripts/verify.php /usr/local/share/php-security/verify.php

RUN rm -f /usr/src/php.tar.xz.asc \
    && printf 'session.upload_progress.enabled=0\n' > /usr/local/etc/php/conf.d/zz-security.ini \
    && php /usr/local/share/php-security/verify.php \
    && php-fpm -t

LABEL org.opencontainers.image.title="PHP 7.3 Apache with Sury security backports" \
      org.opencontainers.image.source="https://github.com/devitools/dockerfile" \
      devitools.php.security-fixes="CVE-2026-109618,CVE-2026-109619" \
      devitools.php.patch-source="Sury php7.3 7.3.33-35"
