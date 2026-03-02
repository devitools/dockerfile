---
applyTo: "**/plan.md"
---

Após criar ou atualizar este arquivo `plan.md`, execute o comando abaixo para notificar o Arandu (visualizador Markdown) e abrir o arquivo automaticamente:

```bash
arandu "<caminho absoluto do plan.md>"
```

O comando é sempre seguro de chamar:
- Se `ARANDU_PORT` não estiver configurado → silencioso, sem efeito
- Se o Arandu não estiver rodando → silencioso, sem efeito
- Se funcionar → o Arandu abre o arquivo com live reload ativo

Use sempre o caminho absoluto do arquivo.
