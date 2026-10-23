# PHP 7.3 Apache compatibility image

`devitools/php-apache:7.3` replaces the public `webdevops/php-apache:7.3` image for existing linux/amd64 deployments. The existing build-images workflow publishes this tag after merge to main. This directory deliberately does not define a `latest` alias.

## Security patch provenance

The original image is pinned to `sha256:aec98f365a8f9e35ff354ac1c0893ba15141807557f40f31f02fea6ed540c43b`. Its PHP is compiled under `/usr/local`, not managed by Debian packages. Installing Sury binary packages alongside it would leave the PHP used by FPM unchanged.

Instead, the builder downloads the checksum-pinned Debian source package `php7.3_7.3.33-35+0~20261021.144+debian12~1.gbpecf76f.debian.tar.xz` from [Sury](https://packages.sury.org/php/pool/main/p/php7.3/). It applies these unmodified patches to the checksum-pinned upstream PHP 7.3.33 source included in the original image:

- `0079-Introduce-max_multipart_body_parts-INI.patch`: the multipart limit prerequisite assumed by the later backport.
- `0107-backport-ZSTR_MAX_LEN.patch`: the string-length definitions required by the later backport.
- `0139-Avoid-state-corruption-via-bailout.patch`: Sury's backport for CVE-2026-109618 and CVE-2026-109619.

The build reuses the original configure options and compiler flags, rebuilds CLI, FPM, sodium and OPcache, and installs binaries and headers under the original paths. Existing additional extensions are inherited unchanged. The `/usr/src/php.tar.xz` archive is also replaced with the patched source for downstream `docker-php-ext-install` builds; the obsolete upstream archive signature is removed. Only these three patches are applied; this image does **not** contain every other fix from Sury revision 35 and does not install Sury binary `.deb` packages. PHP still reports 7.3.33, so `php -v` alone does not identify the fix and version-only scanners may continue to flag these CVEs. Use the recorded patch provenance and behavioral test results when assessing this image.

The source revision, checksum, patches, Sury changelog and original extension inventory are recorded in `/usr/local/share/php-security/`. Build tools and archived Debian repositories are confined to the builder stage.

`session.upload_progress.enabled=0` is set in `/usr/local/etc/php/conf.d/zz-security.ini`, following the [PHP advisory of October 23, 2026](https://www.php.net/archive/2026.php). Keep this setting disabled in custom configuration, including mounted INI files.

## Compatibility

The final stage inherits the original image, preserving:

- `/opt/docker` entrypoint, service scripts, Supervisor, Apache and FPM configuration.
- `/app`, the `application` user (UID/GID 1000), exposed ports and volume behavior.
- `WEB_DOCUMENT_ROOT`, `WEB_ALIAS_DOMAIN`, `PHP_*`, `PHP_DISMOD`, `php.*`, `fpm.pool.*`, `fpm.global.*`, and other original environment handling.
- Existing `/opt/docker/etc/php/php.ini`, `/usr/local/etc/php/conf.d`, Apache and FPM configuration mounts.
- The exact loaded extension names from the pinned original image, including ionCube, vips, amqp, redis, memcached, mongodb and imagick. The build fails if extension parity is lost.

Third-party extensions retain their original versions. Application-specific behavior, encoded ionCube applications and downstream images that compile additional extensions still require staging validation. Rebuild downstream extensions against the updated headers when possible.

The security backport terminates a worker immediately on PHP memory exhaustion rather than attempting unsafe cleanup; shutdown callbacks may not run after OOM. The added multipart limit defaults to `max_input_vars + max_file_uploads` and can reject unusually large multipart requests. Review applications that depend on either behavior.

## Build and validate

```sh
docker build --platform linux/amd64 -t devitools/php-apache:7.3 php-apache/7.3
python3 php-apache/7.3/.scripts/smoke.py devitools/php-apache:7.3
```

Build-time checks verify the PHP version, complete extension-name parity, multipart prerequisite, upload progress setting and FPM configuration syntax. Apache configuration syntax is checked by the smoke test after the entrypoint renders its templates. The smoke test starts the normal entrypoint, exercises HTTP through Apache/FPM with a custom document root and PHP environment values, verifies representative extensions, checks configuration mounts and module disabling, and verifies that OOM skips unsafe shutdown callbacks and FPM can serve a subsequent request.

For deployment, change only the image reference in your Compose service and retain its environment, mounts, ports and other settings. Recreate the containers; pulling a new image does not update running workers.

PHP 7.3 and Debian Buster remain end of life. This is a narrowly scoped compatibility bridge for the two named CVEs, not a fully maintained operating system or PHP distribution. Plan migration to a supported PHP branch.
