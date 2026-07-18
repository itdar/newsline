<div align="center">

[English](../README.md) · [한국어](ko.md) · [日本語](ja.md) · [Español](es.md) · [Français](fr.md) · [Deutsch](de.md) · **Português** · [中文](zh.md)

</div>

# newsline

**Esperando o Claude Code terminar? Leia as últimas notícias em uma linha, direto na sua barra de status.**
Uma manchete regional rotativa fica na parte de baixo da sua sessão — então uma longa espera vira uma
olhada rápida nas notícias. Ela aparece *abaixo* da sua barra de status atual (seu HUD permanece).

<p align="center"><img src="../docs/demo.gif" alt="newsline — manchetes regionais rotativas na barra de status do Claude Code" width="720"></p>

## Instalar e executar — uma linha

```sh
# curl (macOS / Linux / WSL) — instala e configura na hora
curl -fsSL https://raw.githubusercontent.com/itdar/newsline/master/install.sh | sh

# Homebrew
brew install itdar/tap/newsline && newsline init

# npm
npm i -g newsline-cli && newsline init
```

A linha de notícias aparece na sua **próxima mensagem** — sem reiniciar. A configuração pergunta o
idioma e o tema, e mantém a sua barra de status atual.

## O que faz

- **Sua máquina busca e exibe as notícias** — ela nunca toca no seu código, prompts, arquivos ou
  conversas com o Claude.
- Um pequeno **serviço edge** escolhe as melhores fontes regionais e roteia os cliques nas manchetes,
  mantendo as fontes atualizadas sem reinstalar. Se estiver inacessível, o newsline **usa os feeds
  integrados como alternativa**.
- A barra de status é instantânea (servida de um cache); as atualizações rodam em segundo plano.

## Privacidade

Tudo o que roda na sua máquina está neste repositório — e esta é a lista completa do que
sai dela:

- **Curadoria de feeds** (no máximo uma vez por hora): `lang`, país aproximado, hora local,
  dia da semana, fuso horário, `topic` e a versão do plugin são enviados ao serviço edge para
  escolher fontes regionais atualizadas. Sem ID de rastreamento, sem dados pessoais.
- **Cliques nas manchetes**: os links abrem por um pequeno redirecionamento (ele vê a URL do
  artigo mais `lang`/`topic`/versão), para trocar fontes mortas no servidor e contar cliques
  de forma agregada. Não há identificador por usuário.
- **Nunca enviado, nunca lido**: seu código, prompts, arquivos ou conversas com o Claude. A
  barra de status é desenhada de um cache local e nunca espera pela rede.

**Modo totalmente local**: defina `"api": "off"` e `"endpoint": "off"` em
`~/.config/newsline/config.json` — os feeds vêm do `feeds.json` incluído e as manchetes
apontam direto para os artigos. Nada além dos próprios feeds é contatado.

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

## Desinstalar

```sh
newsline uninstall      # restaura a sua barra de status anterior
```

Precisa de `bash` + `python3` (macOS / Linux; Windows via WSL).
