set -euxo pipefail

php -r '$m = get_loaded_extensions(); sort($m); file_put_contents("/tmp/upstream-modules.json", json_encode($m));'
php-config --configure-options > /tmp/configure-options
. /etc/os-release
case "$VERSION_CODENAME" in
    stretch|buster)
        find /etc/apt -type f \( -name '*.list' -o -name '*.sources' \) -exec sed -i \
            -e 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' \
            -e 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' {} +
        ;;
esac
find /etc/apt -type f -name '*.list' -exec sed -i \
    -e '/nginx\.org/d' -e '/stretch-updates/d' {} +
apt-get -o Acquire::Check-Valid-Until=false update
build_deps=(libcurl4-openssl-dev libedit-dev libreadline-dev libsqlite3-dev libxml2-dev zlib1g-dev)
case "$EXPECTED_PHP_VERSION" in
    5.6.*|7.0.*) build_deps+=(libssl1.0-dev) ;;
    *) build_deps+=(libargon2-dev libonig-dev libsodium-dev libssl-dev) ;;
esac
apt-get install -y --no-install-recommends $PHPIZE_DEPS patch "${build_deps[@]}"

mkdir -p /security /tmp/sury /usr/src/php /patched
curl -fsSL --retry 3 "$SURY_SOURCE_URL" -o /tmp/sury.tar.xz
printf '%s  %s\n' "$SURY_SOURCE_SHA256" /tmp/sury.tar.xz | sha256sum -c -
tar -xJf /tmp/sury.tar.xz -C /tmp/sury
printf '%s  %s\n' "$PHP_SOURCE_SHA256" /usr/src/php.tar.xz | sha256sum -c -
tar -xJf /usr/src/php.tar.xz -C /usr/src/php --strip-components=1
bash /tmp/build/apply-patches.sh /usr/src/php
cp /tmp/sury/debian/changelog /security/sury-changelog
cp /tmp/build/patches.list /security/patches.list
cp /tmp/upstream-modules.json /security/upstream-modules.json
printf '%s\n' "$SURY_SOURCE_URL" > /security/source-url
printf '%s\n' "$SURY_SOURCE_SHA256" > /security/source-sha256
printf '%s\n' "$PHP_SOURCE_SHA256" > /security/upstream-source-sha256
export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS"
read -r -a original_options < /tmp/configure-options
configure_options=()
for option in "${original_options[@]}"; do
    case "$option" in --*) configure_options+=("$option") ;; esac
done
cd /usr/src/php
./configure "${configure_options[@]}" --enable-opcache=shared
make -j"$BUILD_JOBS"
make install INSTALL_ROOT=/patched
rm -rf /patched/usr/local/etc /patched/usr/local/php /patched/usr/local/var
cp /tmp/configure-options /security/upstream-configure-options
test "$(php-config --extension-dir)" = "$(/patched/usr/local/bin/php-config --extension-dir)"
test "$(/patched/usr/local/bin/php -n -r 'echo PHP_VERSION;')" = "$EXPECTED_PHP_VERSION"
mkdir -p /tmp/patched-source/php
tar -xJf /usr/src/php.tar.xz -C /tmp/patched-source/php --strip-components=1
bash /tmp/build/apply-patches.sh /tmp/patched-source/php
tar -cJf /tmp/php-patched.tar.xz -C /tmp/patched-source php
