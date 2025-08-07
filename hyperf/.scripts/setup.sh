set -e

TIMEZONE=${1:-UTC}

git config --global --add safe.directory /opt/www
git config --global init.defaultBranch main

# - config PHP
cd /etc/php83
{
    echo "upload_max_filesize=128M"
    echo "post_max_size=128M"
    echo "memory_limit=1G"
    echo "date.timezone=${TIMEZONE}"
} | tee conf.d/99_overrides.ini

# - config timezone
ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
echo "${TIMEZONE}" > /etc/timezone
