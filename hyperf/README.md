# Devitools Hyperf Docker Image

## Introduction
This Docker image is designed to provide an optimized environment for **Hyperf** applications running **PHP 8.3**, supporting both development and production environments.

It includes specific configurations for **Xdebug**, **Sonar Scanner**, PHP performance tuning, and static code analysis support.

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
docker build --platform="linux/amd64" --build-arg APP_TARGET=dev -t devitools/hyperf:8.3-dev .
```

### 🔹 **Production Image**
Removes development tools to optimize the runtime environment.

```sh
docker build --platform="linux/amd64" -t devitools/hyperf:8.3 .
```

---

## 🚀 Differences Between Versions

| Version                | Included Features |
|------------------------|------------------|
| `devitools/hyperf:8.3-dev` | PHP 8.3 + Xdebug + PCOV + Sonar Scanner |
| `devitools/hyperf:8.3`     | PHP 8.3 optimized for production |

---

## 🛠 Usage
To run a container based on the image:

```sh
docker run --rm -it devitools/hyperf:8.3-dev php -v
```

To start a Hyperf project with the image:

```sh
docker run --rm -it -v $(pwd):/opt/www devitools/hyperf:8.3-dev composer create-project hyperf/hyperf-skeleton .
```

---

## 📌 Conclusion
This image provides a complete environment for developing and running Hyperf applications, ensuring productivity and code quality.
