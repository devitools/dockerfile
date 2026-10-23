# Images

Conjunto de imagens usadas pelo Devitools

## Configuração

```shell
$ sudo ln -s $(pwd)/build.sh /usr/bin/dbr
```

## Criando um build

> dbr {image} {version}

```shell
$ dbr vue 3.0.0
```

## PHP 7.3 com Apache

[`devitools/php-apache:7.3`](php-apache/7.3/README.md): substituta de compatibilidade para `webdevops/php-apache:7.3`, com backports do pacote-fonte Surý para CVE-2026-109618 e CVE-2026-109619. Consulte as instruções de build, validação e as limitações de suporte antes de migrar.
