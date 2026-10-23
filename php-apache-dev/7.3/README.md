# php-apache-dev:7.3 security compatibility image

`devitools/php-apache-dev:7.3` is a linux/amd64 replacement for `webdevops/php-apache-dev:7.3`. Merging this directory triggers the existing build-images workflow to publish exactly this tag; no latest alias is added.

## Security and provenance

The upstream image is pinned to `sha256:d3e8d681cfdb0c1961fd8802be9c8385296583e2565c52bde199a436e7555493` and PHP source to `166eaccde933381da9516a2b70ad0f447d7cec4b603d07b9a916032b215b90cc`. PHP remains `7.3.33` and is rebuilt under `/usr/local` with its original configure options and compiler flags. Original trailing configure environment assignments are restored through the image's compiler environment rather than parsed as options.

The checksum-pinned [Sury source package](https://packages.sury.org/php/pool/main/p/php7.3/php7.3_7.3.33-35%2B0~20261021.144%2Bdebian12~1.gbpecf76f.debian.tar.xz) provides the CVE-2026-109618 / CVE-2026-109619 backport and these prerequisites:

- `0079-Introduce-max_multipart_body_parts-INI.patch`
- `0107-backport-ZSTR_MAX_LEN.patch`
- `0139-Avoid-state-corruption-via-bailout.patch`

Source package SHA-256: `6708d986af131aa0e0c7ecb65a47babacf2918d43a3d94d31341f64a734aa815`.

Only the listed patches are applied, not the entire Sury package or its unrelated updates. Selected file sections are extracted without modifying their hunks. Full original patches, applied sections, source checksums, Sury changelog, configure options and the original extension inventory are retained in `/usr/local/share/php-security/`.

The builder recompiles CLI, FPM, OPcache and any shared extensions selected by the original configure command. Other extension binaries, including vendor loaders and debugging extensions when present, remain inherited from the pinned image. Updated headers and `/usr/src/php.tar.xz` support downstream extension builds. Obsolete signatures of the original source archive are removed.

`session.upload_progress.enabled=0` is set at startup through `zz-security.ini`, following the [PHP advisory](https://www.php.net/archive/2026.php). OOM now exits the worker immediately; shutdown callbacks may not run. The multipart part limit defaults to `max_input_vars + max_file_uploads`.

## Compatibility and validation

The original entrypoint, Supervisor, web server, FPM configuration, `/opt/docker` paths, `/app`, user IDs, ports, mounts and environment handling are inherited. The build requires exact CLI extension-name parity. The smoke test checks FPM extension parity allowing its SAPI-specific `cgi-fcgi` registration, web server/FPM configuration, HTTP, file upload, document root, mounted INI, memory environment values, PHP_DISMOD, OOM callback suppression and subsequent HTTP availability.

```sh
docker build --platform linux/amd64 -t devitools/php-apache-dev:7.3 php-apache-dev/7.3
python3 php-apache-dev/7.3/.scripts/smoke.py devitools/php-apache-dev:7.3
```

For deployment, replace the Compose image reference and recreate the container while keeping application configuration. Custom INI mounts must preserve the disabled upload-progress setting. Encoded applications, vendor tools and application-specific extension behavior need staging validation. PHP remains end of life; this is a compatibility bridge for the named CVEs, not a complete security update or a maintained PHP distribution.
