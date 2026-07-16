# newsline

**Waiting for Claude Code to finish? Read the latest one-line news right in your status line.**
A rotating regional headline sits at the bottom of your session — so a long wait turns into a
quick news check. It shows *below* your existing status line (your HUD stays).

**English** · [한국어](readme/ko.md)

## Install & run — one line

```sh
# curl (macOS / Linux / WSL) — installs and sets up right away
curl -fsSL https://raw.githubusercontent.com/itdar/cc-plugin/master/install.sh | sh

# Homebrew
brew install itdar/tap/newsline && newsline init

# npm
npm i -g newsline-cli && newsline init
```

The news line appears on your **next message** — no restart. Setup asks for a language & topic
and keeps your existing status line.

## What it does

- **Your machine fetches and shows the news** — it never touches your code, prompts, files, or
  Claude conversations.
- A small **edge service** picks the best regional sources and routes headline clicks, so sources
  stay fresh without reinstalling. If it's unreachable, newsline **falls back to built-in feeds**.
- The status line is instant (served from a cache); refreshes run in the background.

## Configure

Re-run `newsline init`, or edit `~/.config/newsline/config.json`:

| Key | Default | Meaning |
|---|---|---|
| `lang` | `auto` | `ko` `ja` `en` `es` `fr` `de` `pt` `zh`, or `auto` |
| `topic` | `general` | `general` `tech` `business` `world` `sports` `science` `health` `entertainment` |
| `rotate` | `6` | seconds per headline |
| `count` | `15` | headlines in rotation |
| `maxlen` | `120` | max characters (`max` = no cut) |
| `icon` | `📰` | leading glyph (`none` to hide) |

## Uninstall

```sh
newsline uninstall      # restores your previous status line
```

Needs `bash` + `python3` (macOS / Linux; Windows via WSL).
