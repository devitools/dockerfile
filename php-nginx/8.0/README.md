# php-nginx:8.0 security compatibility image

`devitools/php-nginx:8.0` is a linux/amd64 replacement for `webdevops/php-nginx:8.0`. Merging this directory triggers the existing build-images workflow to publish exactly this tag; no latest alias is added.

## Security and provenance

The upstream image is pinned to `sha256:3377d9a7cd7f4da0a7cd073ff0208b212bc5c73e2a112a7e983b353d30295635` and PHP source to `216ab305737a5d392107112d618a755dc5df42058226f1670e9db90e77d777d9`. PHP remains `8.0.30` and is rebuilt under `/usr/local` with its original configure options and compiler flags. Original trailing configure environment assignments are restored through the image's compiler environment rather than parsed as options.

The checksum-pinned [Sury source package](https://packages.sury.org/php/pool/main/p/php8.0/php8.0_8.0.30-25%2B0~20261021.88%2Bdebian12~1.gbpabebea.debian.tar.xz) provides the CVE-2026-109618 / CVE-2026-109619 backport and these prerequisites:

- `0109-GHSA-m8rr-4c36-8gq4-Consistently-pass-unsigned-char-.patch main/rfc1867.c` (only the `main/rfc1867.c` diff section is applied)
- `0137-Avoid-state-corruption-via-bailout.patch`

Source package SHA-256: `8dd2d897829859df423919744fa4db2a4a61c027ffa6afdef01d276262f5df6e`.

Only the listed patches are applied, not the entire Sury package or its unrelated updates. Selected file sections are extracted without modifying their hunks. Full original patches, applied sections, source checksums, Sury changelog, configure options and the original extension inventory are retained in `/usr/local/share/php-security/`.

The builder recompiles CLI, FPM, OPcache and any shared extensions selected by the original configure command. Other extension binaries, including vendor loaders and debugging extensions when present, remain inherited from the pinned image. Updated headers and `/usr/src/php.tar.xz` support downstream extension builds. Obsolete signatures of the original source archive are removed.

`session.upload_progress.enabled=0` is set at startup through `zz-security.ini`, following the [PHP advisory](https://www.php.net/archive/2026.php). OOM now exits the worker immediately; shutdown callbacks may not run. The multipart part limit defaults to `max_input_vars + max_file_uploads`.

## Compatibility and validation

The original entrypoint, Supervisor, web server, FPM configuration, `/opt/docker` paths, `/app`, user IDs, ports, mounts and environment handling are inherited. The build requires exact CLI extension-name parity. The smoke test checks FPM extension parity allowing its SAPI-specific `cgi-fcgi` registration, web server/FPM configuration, HTTP, file upload, document root, mounted INI, memory environment values, PHP_DISMOD, OOM callback suppression and subsequent HTTP availability.

```sh
docker build --platform linux/amd64 -t devitools/php-nginx:8.0 php-nginx/8.0
python3 php-nginx/8.0/.scripts/smoke.py devitools/php-nginx:8.0
```

For deployment, replace the Compose image reference and recreate the container while keeping application configuration. Custom INI mounts must preserve the disabled upload-progress setting. Encoded applications, vendor tools and application-specific extension behavior need staging validation. PHP remains end of life; this is a compatibility bridge for the named CVEs, not a complete security update or a maintained PHP distribution.
