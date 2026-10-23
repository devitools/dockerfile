set -euxo pipefail

php -r '$m = get_loaded_extensions(); sort($m); file_put_contents("/tmp/upstream-modules.json", json_encode($m));'
php-config --configure-options > /tmp/configure-options
sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g; s|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list
apt-get -o Acquire::Check-Valid-Until=false update
apt-get install -y --no-install-recommends $PHPIZE_DEPS patch \
    libargon2-dev libcurl4-openssl-dev libedit-dev libonig-dev \
    libreadline-dev libsodium-dev libsqlite3-dev libssl-dev libxml2-dev zlib1g-dev

mkdir -p /security /tmp/sury /usr/src/php /patched
curl -fsSL "https://packages.sury.org/php/pool/main/p/php7.3/php7.3_${SURY_SOURCE_VERSION}.debian.tar.xz" -o /tmp/sury.tar.xz
printf '%s  %s\n' "$SURY_SOURCE_SHA256" /tmp/sury.tar.xz | sha256sum -c -
tar -xJf /tmp/sury.tar.xz -C /tmp/sury
printf '%s  %s\n' 166eaccde933381da9516a2b70ad0f447d7cec4b603d07b9a916032b215b90cc /usr/src/php.tar.xz | sha256sum -c -
tar -xJf /usr/src/php.tar.xz -C /usr/src/php --strip-components=1
cd /usr/src/php
for name in 0079-Introduce-max_multipart_body_parts-INI.patch 0139-Avoid-state-corruption-via-bailout.patch; do
    patch --batch --fuzz=0 -p1 < "/tmp/sury/debian/patches/$name"
    cp "/tmp/sury/debian/patches/$name" /security/
done
cp /tmp/sury/debian/changelog /security/sury-changelog
cp /tmp/upstream-modules.json /security/upstream-modules.json
printf '%s\n' "$SURY_SOURCE_VERSION" > /security/source-version
printf '%s\n' "$SURY_SOURCE_SHA256" > /security/source-sha256
export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS"
read -r -a configure_options < /tmp/configure-options
./configure "${configure_options[@]}" --enable-opcache=shared
make -j"$BUILD_JOBS"
make install INSTALL_ROOT=/patched
rm -rf /patched/usr/local/etc /patched/usr/local/php /patched/usr/local/var
cp /tmp/configure-options /security/upstream-configure-options
/patched/usr/local/bin/php -n -r 'exit(PHP_VERSION === "7.3.33" ? 0 : 1);'
