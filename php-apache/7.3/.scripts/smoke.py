import json
import pathlib
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.request

image = sys.argv[1] if len(sys.argv) > 1 else "devitools/php-apache:7.3"


def docker(*args, check=True):
    return subprocess.run(["docker", *args], check=check, text=True, capture_output=True)


def require(condition, message):
    if not condition:
        raise RuntimeError(message)


with tempfile.TemporaryDirectory(prefix="php73-sury-") as directory:
    root = pathlib.Path(directory)
    app = root / "app"
    app.mkdir()
    app.joinpath("index.php").write_text('''<?php
header('Content-Type: application/json');
$db = new PDO('sqlite::memory:');
$im = imagecreatetruecolor(2, 2);
ob_start();
imagepng($im);
$png = ob_get_clean();
$modules = get_loaded_extensions();
sort($modules);
echo json_encode([
    'version' => PHP_VERSION,
    'sapi' => PHP_SAPI,
    'memory_limit' => ini_get('memory_limit'),
    'mounted' => ini_get('precision'),
    'upload_progress' => ini_get('session.upload_progress.enabled'),
    'multipart_limit' => ini_get('max_multipart_body_parts'),
    'sqlite' => $db->query('SELECT 42')->fetchColumn(),
    'gd' => strlen($png) > 0,
    'mbstring' => mb_strlen('á', 'UTF-8'),
    'modules' => $modules,
    'post' => $_POST,
    'files' => count($_FILES),
]);
''')
    app.joinpath("oom.php").write_text('''<?php
register_shutdown_function(function () { file_put_contents('/tmp/unsafe-shutdown', 'ran'); });
ini_set('memory_limit', '16M');
$x = str_repeat('x', 64 * 1024 * 1024);
''')
    custom = root / "custom.ini"
    custom.write_text("precision=12\n")
    cid = docker(
        "run", "-d", "--platform", "linux/amd64", "-p", "127.0.0.1::80",
        "-e", "WEB_DOCUMENT_ROOT=/app/public", "-e", "PHP_MEMORY_LIMIT=96M",
        "-v", f"{app}:/app/public:ro",
        "-v", f"{custom}:/opt/docker/etc/php/php.ini:ro", image,
    ).stdout.strip()
    try:
        port = docker("port", cid, "80/tcp").stdout.strip().split(":")[-1]
        base = f"http://127.0.0.1:{port}"
        for attempt in range(60):
            try:
                with urllib.request.urlopen(base, timeout=2) as response:
                    data = json.load(response)
                break
            except (OSError, ValueError):
                time.sleep(1)
        else:
            raise RuntimeError("Apache/FPM did not become ready")
        docker("exec", cid, "apache2ctl", "-t")
        docker("exec", cid, "php-fpm", "-t")
        require(data["version"] == "7.3.33", "Wrong PHP version")
        require(data["sapi"] == "fpm-fcgi", "HTTP is not using FPM")
        require(data["memory_limit"] == "96M", "PHP environment not applied")
        require(data["mounted"] == "12", "Mounted INI not applied")
        require(not data["upload_progress"], "Upload progress is enabled")
        require(data["multipart_limit"] == "-1", "Missing multipart prerequisite")
        require(int(data["sqlite"]) == 42 and data["gd"] and data["mbstring"] == 1, "Extension functional check failed")
        expected = json.loads(docker("exec", cid, "cat", "/usr/local/share/php-security/upstream-modules.json").stdout)
        require(data["modules"] == expected, "HTTP extension parity failed")
        boundary = "php73-sury-smoke"
        body = (
            f"--{boundary}\r\nContent-Disposition: form-data; name=field\r\n\r\nvalue\r\n"
            f"--{boundary}\r\nContent-Disposition: form-data; name=file; filename=test.txt\r\n"
            f"Content-Type: text/plain\r\n\r\nsafe upload\r\n--{boundary}--\r\n"
        ).encode()
        request = urllib.request.Request(base, data=body, headers={"Content-Type": f"multipart/form-data; boundary={boundary}"})
        with urllib.request.urlopen(request, timeout=5) as response:
            uploaded = json.load(response)
        require(uploaded["post"] == {"field": "value"} and uploaded["files"] == 1, "Multipart upload failed")
        try:
            urllib.request.urlopen(base + "/oom.php", timeout=10).close()
        except (OSError, urllib.error.HTTPError):
            pass
        require(docker("exec", cid, "test", "!", "-e", "/tmp/unsafe-shutdown", check=False).returncode == 0, "Unsafe OOM shutdown callback executed")
        with urllib.request.urlopen(base, timeout=10) as response:
            require(json.load(response)["version"] == "7.3.33", "FPM did not recover after OOM")
        cli = docker("exec", cid, "php", "/usr/local/share/php-security/verify.php")
        print(cli.stdout.strip())
    except Exception:
        print(docker("logs", cid, check=False).stdout, file=sys.stderr)
        print(docker("logs", cid, check=False).stderr, file=sys.stderr)
        raise
    finally:
        docker("rm", "-f", cid, check=False)

oom = docker(
    "run", "--rm", "--platform", "linux/amd64", "--entrypoint", "php", image,
    "-d", "memory_limit=16M", "-r",
    "register_shutdown_function(function () { echo 'UNSAFE_SHUTDOWN'; }); str_repeat('x', 64 * 1024 * 1024);",
    check=False,
)
require(oom.returncode == 1 and "Allowed memory size" in oom.stderr, "OOM did not follow the patched immediate-exit path")
require("UNSAFE_SHUTDOWN" not in oom.stdout, "Unsafe CLI OOM shutdown callback executed")

result = docker(
    "run", "--rm", "--platform", "linux/amd64", "-e", "PHP_DISMOD=redis,imagick",
    image, "php", "-r", "exit(extension_loaded('redis') || extension_loaded('imagick') ? 1 : 0);",
)
print("Apache/FPM HTTP, multipart, INI mounts, environment, extensions, OOM recovery and PHP_DISMOD passed")
