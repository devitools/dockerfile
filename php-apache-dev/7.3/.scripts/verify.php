<?php
$expected = json_decode(file_get_contents(isset($argv[1]) ? $argv[1] : __DIR__ . '/upstream-modules.json'), true);
$actual = get_loaded_extensions();
sort($actual);
if ($actual !== $expected) {
    fwrite(STDERR, 'Extension mismatch: ' . json_encode(array_diff($expected, $actual)) . PHP_EOL);
    exit(1);
}
if (PHP_VERSION !== '7.3.33' || PHP_ZTS || PHP_DEBUG || ini_get('session.upload_progress.enabled')) {
    fwrite(STDERR, 'Unexpected PHP version, ABI or upload progress setting' . PHP_EOL);
    exit(1);
}
if (ini_get('max_multipart_body_parts') === false) {
    fwrite(STDERR, 'Missing multipart prerequisite patch' . PHP_EOL);
    exit(1);
}
echo 'PHP version, extension parity and security configuration verified', PHP_EOL;
