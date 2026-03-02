---
name: copilot-sandbox-arandu
description: Integração com o Arandu (visualizador Markdown). Use quando o usuário mencionar "arandu", pedir para visualizar o plano, ou quando um plan.md for criado/atualizado e ARANDU_PORT estiver configurado.
---

# Arandu — Visualizador Markdown integrado

O **Arandu** é um visualizador Markdown com live reload instalado no host. A integração com o Copilot Sandbox permite abrir arquivos automaticamente no Arandu via socket TCP.

## Como funciona

1. O usuário configura `ARANDU_PORT` no shell do host (ex: `export ARANDU_PORT="7474"`)
2. O Copilot Sandbox propaga essa variável ao container
3. Após criar ou atualizar um `plan.md`, o Copilot chama `arandu <caminho>` para notificar o Arandu
4. O Arandu abre o arquivo e ativa o live reload — o usuário vê o plano sendo atualizado em tempo real

## Contrato do socket

- **Variáveis**: `$ARANDU_PORT` — porta TCP do Arandu; `$ARANDU_HOST` — host do Arandu (padrão interno: `host.docker.internal`)
- **Protocolo**: JSON newline-delimited
  ```json
  {"command":"open","path":"/caminho/absoluto/do/arquivo.md"}
  ```

## Ferramenta disponível: `arandu`

```bash
arandu /caminho/absoluto/do/arquivo.md
```

- Se `ARANDU_PORT` não estiver definido → silencioso, sem erros
- Se o Arandu não estiver rodando → silencioso, sem erros
- Sempre usar caminho absoluto

## Quando usar

- Após criar `plan.md` em qualquer sessão
- Após atualizar `plan.md` com progresso significativo
- Quando o usuário pedir explicitamente para abrir um arquivo no Arandu

## Exemplo de uso

```bash
# Criar plano e abrir no Arandu
create plan.md "..."
arandu "$HOME/.copilot/session-state/session-id/plan.md"
```
