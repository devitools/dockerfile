set -e

SONAR_SCANNER_VERSION=6.2.1.4610

if [ "$1" = "dev" ]; then
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
      libc6-compat \
      openjdk17-jre \
      php83-pecl-xdebug \
      php83-pecl-pcov

  {
    echo "opcache.enable=0"
    echo "opcache.interned_strings_buffer=72"
    echo "xdebug.mode=develop,debug,coverage"
    echo "xdebug.idekey=PHPSTORM"
  } >> /etc/php83/conf.d/zzz_2_php.ini

  mkdir -p /opt
  SONAR_BASE_URL=https://binaries.sonarsource.com/Distribution/sonar-scanner-cli
  SONAR_ASSET=sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux-x64.zip
  curl -fSL "${SONAR_BASE_URL}/${SONAR_ASSET}" -o "/opt/${SONAR_ASSET}"
  curl -fSL "${SONAR_BASE_URL}/${SONAR_ASSET}.sha256" -o "/opt/${SONAR_ASSET}.sha256"
  (cd /opt && echo "$(cat "${SONAR_ASSET}.sha256")  ${SONAR_ASSET}" | sha256sum -c -)

  unzip -qq "/opt/${SONAR_ASSET}" -d /opt
  mv /opt/sonar-scanner-${SONAR_SCANNER_VERSION}-linux-x64 /sonar-scanner
  rm "/opt/${SONAR_ASSET}" "/opt/${SONAR_ASSET}.sha256"

  ln -s /sonar-scanner/bin/sonar-scanner /bin/sonar-scanner

  sed -i 's/use_embedded_jre=true/use_embedded_jre=false/g' /sonar-scanner/bin/sonar-scanner
fi
