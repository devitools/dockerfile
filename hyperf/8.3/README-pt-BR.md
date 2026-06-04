# Devitools Hyperf Docker Image

## Introdução
Esta imagem Docker foi criada para fornecer um ambiente otimizado para aplicações **Hyperf** em **PHP 8.3**, suportando tanto ambientes de desenvolvimento quanto de produção.

Ela inclui configurações específicas para **Xdebug**, **Sonar Scanner**, ajustes de performance no PHP e suporte a análise estática de código.

---

## 📦 Conteúdo da Imagem
A imagem contém:
- **PHP 8.3** com extensões essenciais
- **Composer** para gerenciamento de dependências
- **Xdebug** e **PCOV** para depuração e cobertura de código
- **Sonar Scanner** para análise de qualidade de código
- **Configuração de timezone** ajustável
- **Suporte a análise de código via SonarQube**

---

## 🛠️ Configuração e Instalação
A configuração da imagem é realizada através dos scripts:

### `setup.sh`
- Ajusta configurações do PHP, incluindo **limite de memória**, **upload_max_filesize**, e **timezone**.
- Configura o timezone do sistema.

### `setup-dev.sh`
- Instala dependências para desenvolvimento, incluindo **Xdebug** e **Sonar Scanner**.
- Configura `xdebug.ini` para integração com **PHPStorm**.
- Desativa **JRE embutido** no Sonar Scanner para evitar conflitos.

---

## 📌 Como Construir a Imagem
A imagem pode ser construída de duas formas: **para desenvolvimento** e **para produção**.

### 🔹 **Imagem de Desenvolvimento**
Inclui **Xdebug**, **PCOV** e **Sonar Scanner** para depuração e análise de código.

```sh
docker build --platform="linux/amd64" --build-arg APP_TARGET=dev -t devitools/hyperf:8.3-dev .
```

### 🔹 **Imagem de Produção**
Removendo ferramentas de desenvolvimento para otimizar o ambiente de execução.

```sh
docker build --platform="linux/amd64" -t devitools/hyperf:8.3 .
```

---

## 🚀 Diferenças entre as Versões

| Versão                | Recursos Incluídos |
|-----------------------|------------------|
| `devitools/hyperf:8.3-dev` | PHP 8.3 + Xdebug + PCOV + Sonar Scanner |
| `devitools/hyperf:8.3`     | PHP 8.3 otimizado para produção |

---

## 🛠 Uso
Para rodar um container baseado na imagem:

```sh
docker run --rm -it devitools/hyperf:8.3-dev php -v
```

Para iniciar um projeto Hyperf com a imagem:

```sh
docker run --rm -it -v $(pwd):/opt/www devitools/hyperf:8.3-dev composer create-project hyperf/hyperf-skeleton .
```

---

## 📌 Conclusão
Esta imagem proporciona um ambiente completo para desenvolvimento e execução de aplicações Hyperf, garantindo produtividade e qualidade no código.
