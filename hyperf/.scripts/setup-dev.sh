set -e

SONAR_SCANNER_VERSION=6.2.1.4610

if ! command -v apk &> /dev/null; then
  echo "Error: 'apk' not found. Make sure you are running this script in an Alpine Linux environment." >&2
  exit 1
fi

if ! command -v composer &> /dev/null; then
  echo "Error: 'composer' not found. Make sure it is installed and accessible in the system PATH." >&2
  exit 1
fi

echo "[$1] Installing PHP extensions and dependencies"

apk add --no-cache \
    libstdc++ \
    ca-certificates \
    curl \
    unzip \
    libc6-compat \
    openjdk17-jre \
    php83-pecl-xdebug \
    php83-pecl-pcov

cd /etc/php83
{
  echo "opcache.enable=0"
  echo "opcache.interned_strings_buffer=72"
} >> conf.d/99_php.ini
{
  echo "xdebug.mode=develop,debug,coverage"
  echo "xdebug.idekey=PHPSTORM"
} >> conf.d/50_xdebug.ini

mkdir -p /opt
curl -fSL https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux-x64.zip \
  -o /opt/sonar-scanner.zip

unzip -qq /opt/sonar-scanner.zip -d /opt
mv /opt/sonar-scanner-${SONAR_SCANNER_VERSION}-linux-x64 /sonar-scanner
rm /opt/sonar-scanner.zip

ln -s /sonar-scanner/bin/sonar-scanner /bin/sonar-scanner

sed -i 's/use_embedded_jre=true/use_embedded_jre=false/g' /sonar-scanner/bin/sonar-scanner
