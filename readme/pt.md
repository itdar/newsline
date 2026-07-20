<div align="center">

[English](../README.md) · [한국어](ko.md) · [日本語](ja.md) · [Español](es.md) · [Français](fr.md) · [Deutsch](de.md) · **Português** · [中文](zh.md)

</div>

# newsline

**Esperando o Claude Code terminar? Leia as últimas notícias em uma linha, direto na sua barra de status.**
Uma manchete regional rotativa fica na parte de baixo da sua sessão — então uma longa espera vira uma
olhada rápida nas notícias. Ela aparece *abaixo* da sua barra de status atual (seu HUD permanece).

## Instalar e executar — uma linha

```sh
# curl (macOS / Linux / WSL) — instala e configura na hora
curl -fsSL https://raw.githubusercontent.com/itdar/cc-plugin/master/install.sh | sh

# Homebrew
brew install itdar/tap/newsline && newsline init

# npm
npm i -g newsline-cli && newsline init
```

A linha de notícias aparece na sua **próxima mensagem** — sem reiniciar. A configuração pergunta o
idioma, o tema e a cor da manchete, e mantém a sua barra de status atual.

## O que faz

- **Sua máquina busca e exibe as notícias** — ela nunca toca no seu código, prompts, arquivos ou
  conversas com o Claude.
- Um pequeno **serviço edge** escolhe as melhores fontes regionais e roteia os cliques nas manchetes,
  mantendo as fontes atualizadas sem reinstalar. Se estiver inacessível, o newsline **usa os feeds
  integrados como alternativa**.
- A barra de status é instantânea (servida de um cache); as atualizações rodam em segundo plano.

## Configurar

Execute `newsline init` novamente ou edite `~/.config/newsline/config.json`:

| Chave | Padrão | Significado |
|---|---|---|
| `lang` | `auto` | `ko` `ja` `en` `es` `fr` `de` `pt` `zh`, ou `auto` |
| `topic` | `general` | `general` `tech` `business` `world` `sports` `science` `health` `entertainment` |
| `rotate` | `6` | segundos por manchete |
| `count` | `15` | manchetes na rotação |
| `maxlen` | `120` | máximo de caracteres (`max` = sem corte) |
| `icon` | `📰` | ícone inicial (`none` para ocultar) |
| `color` | `white` | cor da manchete: `default` `white` `cyan` `yellow` `green` `blue` `magenta` `red` |

Ou use `newsline color` — cada execução avança para a próxima cor (default(gray) → white →
cyan → yellow → green → blue → magenta → red), visível no próximo refresh da linha
de status.

## Desinstalar

```sh
newsline uninstall      # restaura a sua barra de status anterior
```

Precisa de `bash` + `python3` (macOS / Linux; Windows via WSL).
