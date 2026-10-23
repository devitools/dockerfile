# php-apache:7.4 security compatibility image

`devitools/php-apache:7.4` is a linux/amd64 replacement for `webdevops/php-apache:7.4`. Merging this directory triggers the existing build-images workflow to publish exactly this tag; no latest alias is added.

## Security and provenance

The upstream image is pinned to `sha256:2f959841830b22ab875c909b023fdcb87de32210cb6d1d6f032a2f3ab7514ed2` and PHP source to `924846abf93bc613815c55dd3f5809377813ac62a9ec4eb3778675b82a27b927`. PHP remains `7.4.33` and is rebuilt under `/usr/local` with its original configure options and compiler flags. Original trailing configure environment assignments are restored through the image's compiler environment rather than parsed as options.

The checksum-pinned [Sury source package](https://packages.sury.org/php/pool/main/p/php7.4/php7.4_7.4.33-31%2B0~20261021.121%2Bdebian12~1.gbpe9c428.debian.tar.xz) provides the CVE-2026-109618 / CVE-2026-109619 backport and these prerequisites:

- `0062-Introduce-max_multipart_body_parts-INI.patch`
- `0136-GHSA-m8rr-4c36-8gq4-Consistently-pass-unsigned-char-.patch main/rfc1867.c` (only the `main/rfc1867.c` diff section is applied)
- `0164-Avoid-state-corruption-via-bailout.patch`

Source package SHA-256: `4747b79a87b89a2591497704df4b80e68c7e78b64fbf23c205dca331ebf83496`.

Only the listed patches are applied, not the entire Sury package or its unrelated updates. Selected file sections are extracted without modifying their hunks. Full original patches, applied sections, source checksums, Sury changelog, configure options and the original extension inventory are retained in `/usr/local/share/php-security/`.

The builder recompiles CLI, FPM, OPcache and any shared extensions selected by the original configure command. Other extension binaries, including vendor loaders and debugging extensions when present, remain inherited from the pinned image. Updated headers and `/usr/src/php.tar.xz` support downstream extension builds. Obsolete signatures of the original source archive are removed.

`session.upload_progress.enabled=0` is set at startup through `zz-security.ini`, following the [PHP advisory](https://www.php.net/archive/2026.php). OOM now exits the worker immediately; shutdown callbacks may not run. The multipart part limit defaults to `max_input_vars + max_file_uploads`.

## Compatibility and validation

The original entrypoint, Supervisor, web server, FPM configuration, `/opt/docker` paths, `/app`, user IDs, ports, mounts and environment handling are inherited. The build requires exact CLI extension-name parity. The smoke test checks FPM extension parity allowing its SAPI-specific `cgi-fcgi` registration, web server/FPM configuration, HTTP, file upload, document root, mounted INI, memory environment values, PHP_DISMOD, OOM callback suppression and subsequent HTTP availability.

```sh
docker build --platform linux/amd64 -t devitools/php-apache:7.4 php-apache/7.4
python3 php-apache/7.4/.scripts/smoke.py devitools/php-apache:7.4
```

For deployment, replace the Compose image reference and recreate the container while keeping application configuration. Custom INI mounts must preserve the disabled upload-progress setting. Encoded applications, vendor tools and application-specific extension behavior need staging validation. PHP remains end of life; this is a compatibility bridge for the named CVEs, not a complete security update or a maintained PHP distribution.
