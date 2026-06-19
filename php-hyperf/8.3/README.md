# Devitools Hyperf

Optimized image for running Hyperf applications with PostgreSQL and Swoole support.

## Introduction

This Docker image is designed to provide an optimized environment for **Hyperf** applications running **PHP 8.3**,
supporting both development and production environments.

It includes specific configurations for **Xdebug**, **Sonar Scanner**, PHP performance tuning, and static code analysis
support.

## 🛠️ How to Use

### Run a Container Directly

```sh
docker run --rm --name hyperf -d -v "$(pwd):/opt/www" -p "8080:9501" --platform linux/amd64 devitools/php-hyperf:8.3-dev
```

### Example `Dockerfile` Ready for Production

```dockerfile
FROM devitools/php-hyperf:8.3

COPY . /opt/www

RUN composer install --prefer-dist --no-dev --optimize-autoloader
```

## 🚀 Example `docker-compose.yml` Ready for dev

```yaml
services:
  app:
    image: devitools/php-hyperf:8.3-dev
    container_name: template_name-app
    command: [ "server:watch" ]
    volumes:
      - ./:/opt/www
    ports:
      - "9501:9501"
    environment:
      - SCAN_CACHEABLE=false
      - STDOUT_LOG_LEVEL=alert,critical,emergency,error,warning,notice,info
    restart: on-failure
```

## 📌 Environment Variables

- `SCAN_CACHEABLE`: Controls Hyperf’s scan cache.
- `STDOUT_LOG_LEVEL`: Sets the log levels sent to `stdout`.

## 🏗️ Just Run, no Build

```sh
docker-compose up -d
```

## 📂 Related Repositories

- **Dockerfile Repository** (Source code for this image):  
  🔗 [github.com/devitools/dockerfile](https://github.com/devitools/dockerfile)

- **Example Project** (Hyperf with this image):  
  🔗 [github.com/phpcomrapadura/hyperf-com-rapadura](https://github.com/phpcomrapadura/hyperf-com-rapadura)

---

## 📦 Image Contents

The image includes:

- **PHP 8.3** with essential extensions
- **Composer** for dependency management
- **Xdebug** and **PCOV** for debugging and code coverage
- **Sonar Scanner** for code quality analysis
- **Adjustable timezone configuration**
- **Support for static code analysis via SonarQube**

---

## 🛠️ Configuration and Installation

The image configuration is handled through the following scripts:

### `setup.sh`

- Adjusts PHP settings, including **memory limit**, **upload_max_filesize**, and **timezone**.
- Configures the system timezone.

### `setup-dev.sh`

- Installs development dependencies, including **Xdebug** and **Sonar Scanner**.
- Configures `xdebug.ini` for **PHPStorm** integration.
- Disables **embedded JRE** in Sonar Scanner to avoid conflicts.

---

## 📌 How to Build the Image

The image can be built in two ways: **for development** and **for production**.

### 🔹 **Development Image**

Includes **Xdebug**, **PCOV**, and **Sonar Scanner** for debugging and code analysis.

```sh
docker build --platform="linux/amd64" --build-arg APP_TARGET=dev -t devitools/php-hyperf:8.3-dev .
```

### 🔹 **Production Image**

Removes development tools to optimize the runtime environment.

```sh
docker build --platform="linux/amd64" -t devitools/php-hyperf:8.3 .
```

## ✨ How to publish the new image

After building the image, you can push it to Docker Hub:

```sh
docker push devitools/php-hyperf:8.3-dev
```

---

## 🚀 Differences Between Versions

The Dockerfile is multi-stage, and the CI pipeline publishes four variants from it:

| Version                           | Stage         | Included Features |
|-----------------------------------|---------------|-------------------|
| `devitools/php-hyperf:8.3`        | `hyperf`      | PHP 8.3 optimized for production |
| `devitools/php-hyperf:8.3-dev`    | `hyperf`      | PHP 8.3 + Xdebug + PCOV + Sonar Scanner (`APP_TARGET=dev`) |
| `devitools/php-hyperf:8.3-otel`   | `hyperf-otel` | Production image + `otelcol-contrib` + `supervisord` + `pgbouncer` (vendor-neutral `debug` exporter) |
| `devitools/php-hyperf:8.3-google` | `hyperf-otel` | Same stack as `-otel`, with the `googlecloud` exporter for GCP/Cloud Run |

---

## 🛠 Usage

To run a container based on the image:

```sh
docker run --rm -it devitools/php-hyperf:8.3-dev php -v
```

To start a Hyperf project with the image:

```sh
docker run --rm -it -v $(pwd):/opt/www devitools/php-hyperf:8.3-dev composer create-project hyperf/hyperf-skeleton .
```

---

## 📌 Conclusion

This image provides a complete environment for developing and running Hyperf applications, ensuring productivity and
code quality.
