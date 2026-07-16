# newsline

Locale-aware one-line news in your Claude Code status line — **fully local**, and it
**composes with your existing status line** (e.g. an HUD) instead of replacing it.

**English** · [한국어](readme/ko.md)

## What it is

A Claude Code status-line utility that shows a rotating, region-appropriate news
headline at the bottom of your session. Everything runs locally on your machine —
locale detection, feed fetch, parsing, caching, rendering. It never reads your code,
prompts, files, or Claude conversations.

## Install

**curl | sh** (macOS / Linux / WSL):
```sh
curl -fsSL https://raw.githubusercontent.com/itdar/cc-plugin/master/install.sh | sh
```

**Homebrew:**
```sh
brew install itdar/tap/newsline
```

**From source:**
```sh
git clone https://github.com/itdar/cc-plugin && cd cc-plugin && ./install.sh
```

The **curl | sh** installer runs setup automatically — it prompts you for a language and
topic, then wires the status line. For **Homebrew** or **from source**, run setup yourself:
```sh
newsline init
```
`init` asks for a language and topic (a menu — just pick a number), then registers the
status line, **keeping whatever status line you already have** (your HUD stays visible,
news shows on the line below). It appears on your next message to Claude — Claude Code
hot-reloads settings, so no restart is needed.

_(Skip auto-setup during install with `NEWSLINE_NO_INIT=1`.)_

## Configure

Choose during `newsline init`, or edit `~/.config/newsline/config.json` (or set the env var):

| Key / env var | Default | Meaning |
|---|---|---|
| `lang` / `NEWSLINE_LANG` | `auto` | `ko` `ja` `en` `es` `fr` `de` `pt` `zh`, or `auto` |
| `topic` / `NEWSLINE_TOPIC` | `general` | `general` `tech` `business` `world` `sports` `science` `health` `entertainment` |
| `rotate` / `NEWSLINE_ROTATE` | `6` | seconds per headline |
| `count` / `NEWSLINE_COUNT` | `15` | headlines cached for rotation |
| `maxlen` / `NEWSLINE_MAXLEN` | `120` | max chars; `max` = no truncation; `NN%` ≈ of terminal width |
| `icon` / `NEWSLINE_ICON` | `📰` | leading glyph; `none` to remove |
| `linkhint` / `NEWSLINE_LINKHINT` | off | append a `↗` "opens externally" hint |
| `api` / `NEWSLINE_API` | — | optional curation API (server-first, local fallback) |
| `endpoint` / `NEWSLINE_ENDPOINT` | — | click-redirect wrapper |

## How it works

- **`newsline render`** (what the status line runs) prints instantly from cache and never
  blocks; it kicks off a background refresh when the cache is stale.
- **`newsline refresh`** fetches a keyless regional RSS/Atom feed locally, parses the top
  headlines, dedupes, and caches them.
- Headlines are clickable [OSC 8] links. Whether a plain click vs `Cmd`/`Ctrl`+click opens
  them is decided by your terminal, not by newsline.

## Uninstall

```sh
newsline uninstall      # removes the wiring and restores your previous status line
```

## Privacy

Runs locally; detects locale from your system settings (no IP geolocation); fetches public
feeds directly; never accesses your code, prompts, files, or Claude conversations. Clicks
pass through a redirect so the project can measure engagement and, in future, use affiliate
links to fund itself — disclosed here.

## Requirements

`bash`, `python3`. macOS and Linux natively; Windows via WSL or Git Bash.

[OSC 8]: https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda
