# php-apache:8.1 security compatibility image

`devitools/php-apache:8.1` is a linux/amd64 replacement for `webdevops/php-apache:8.1`. Merging this directory triggers the existing build-images workflow to publish exactly this tag; no latest alias is added.

## Security and provenance

The upstream image is pinned to `sha256:5c5e09af88e61225f33a2b056c85d8a06eaa1469a652f5320a4d0ce0e57a18ea` and PHP source to `ffa9e0982e82eeaea848f57687b425ed173aa278fe563001310ae2638db5c251`. PHP remains `8.1.34` and is rebuilt under `/usr/local` with its original configure options and compiler flags. Original trailing configure environment assignments are restored through the image's compiler environment rather than parsed as options.

The checksum-pinned [Sury source package](https://packages.sury.org/php/pool/main/p/php8.1/php8.1_8.1.34-9%2B0~20261021.82%2Bdebian12~1.gbp4e430a.debian.tar.xz) provides the CVE-2026-109618 / CVE-2026-109619 backport and these prerequisites:

- `0057-GHSA-m8rr-4c36-8gq4-Consistently-pass-unsigned-char-.patch main/rfc1867.c` (only the `main/rfc1867.c` diff section is applied)
- `0083-Avoid-state-corruption-via-bailout.patch`

Source package SHA-256: `03a83aeb5b1912d7b427e331c1287860d31a3a6c8b49ff40ac83df371283979c`.

Only the listed patches are applied, not the entire Sury package or its unrelated updates. Selected file sections are extracted without modifying their hunks. Full original patches, applied sections, source checksums, Sury changelog, configure options and the original extension inventory are retained in `/usr/local/share/php-security/`.

The builder recompiles CLI, FPM, OPcache and any shared extensions selected by the original configure command. Other extension binaries, including vendor loaders and debugging extensions when present, remain inherited from the pinned image. Updated headers and `/usr/src/php.tar.xz` support downstream extension builds. Obsolete signatures of the original source archive are removed.

`session.upload_progress.enabled=0` is set at startup through `zz-security.ini`, following the [PHP advisory](https://www.php.net/archive/2026.php). OOM now exits the worker immediately; shutdown callbacks may not run. The multipart part limit defaults to `max_input_vars + max_file_uploads`.

## Compatibility and validation

The original entrypoint, Supervisor, web server, FPM configuration, `/opt/docker` paths, `/app`, user IDs, ports, mounts and environment handling are inherited. The build requires exact CLI extension-name parity. The smoke test checks FPM extension parity allowing its SAPI-specific `cgi-fcgi` registration, web server/FPM configuration, HTTP, file upload, document root, mounted INI, memory environment values, PHP_DISMOD, OOM callback suppression and subsequent HTTP availability.

```sh
docker build --platform linux/amd64 -t devitools/php-apache:8.1 php-apache/8.1
python3 php-apache/8.1/.scripts/smoke.py devitools/php-apache:8.1
```

For deployment, replace the Compose image reference and recreate the container while keeping application configuration. Custom INI mounts must preserve the disabled upload-progress setting. Encoded applications, vendor tools and application-specific extension behavior need staging validation. PHP remains end of life; this is a compatibility bridge for the named CVEs, not a complete security update or a maintained PHP distribution.
