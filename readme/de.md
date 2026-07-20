<div align="center">

[English](../README.md) · [한국어](ko.md) · [日本語](ja.md) · [Español](es.md) · [Français](fr.md) · **Deutsch** · [Português](pt.md) · [中文](zh.md)

</div>

# newsline

**Wartest du darauf, dass Claude Code fertig wird? Lies die neuesten Ein-Zeilen-News direkt in deiner Statusleiste.**
Eine rotierende regionale Schlagzeile sitzt am unteren Rand deiner Sitzung – so wird aus langem Warten
ein schneller Blick in die Nachrichten. Sie erscheint *unter* deiner bestehenden Statusleiste (dein HUD
bleibt erhalten).

## Installieren & starten — eine Zeile

```sh
# curl (macOS / Linux / WSL) — installiert und richtet sofort ein
curl -fsSL https://raw.githubusercontent.com/itdar/cc-plugin/master/install.sh | sh

# Homebrew
brew install itdar/tap/newsline && newsline init

# npm
npm i -g newsline-cli && newsline init
```

Die News-Zeile erscheint bei deiner **nächsten Nachricht** – kein Neustart nötig. Die Einrichtung fragt
nach Sprache, Thema und Schlagzeilenfarbe und behält deine bestehende Statusleiste bei.

## Was es macht

- **Dein Rechner holt und zeigt die Nachrichten** – er rührt niemals deinen Code, deine Prompts, Dateien
  oder Claude-Unterhaltungen an.
- Ein kleiner **Edge-Dienst** wählt die besten regionalen Quellen aus und leitet Klicks auf Schlagzeilen
  weiter, sodass die Quellen ohne Neuinstallation aktuell bleiben. Ist er nicht erreichbar, **greift
  newsline auf die integrierten Feeds zurück**.
- Die Statusleiste ist sofort da (aus einem Cache); Aktualisierungen laufen im Hintergrund.

## Konfigurieren

Führe `newsline init` erneut aus oder bearbeite `~/.config/newsline/config.json`:

| Schlüssel | Standard | Bedeutung |
|---|---|---|
| `lang` | `auto` | `ko` `ja` `en` `es` `fr` `de` `pt` `zh` oder `auto` |
| `topic` | `general` | `general` `tech` `business` `world` `sports` `science` `health` `entertainment` |
| `rotate` | `6` | Sekunden pro Schlagzeile |
| `count` | `15` | Schlagzeilen im Wechsel |
| `maxlen` | `120` | maximale Zeichen (`max` = kein Abschneiden) |
| `icon` | `📰` | vorangestelltes Symbol (`none` zum Ausblenden) |
| `color` | `white` | Farbe der Schlagzeile: `default` `white` `cyan` `yellow` `green` `blue` `magenta` `red` |

Oder `newsline color` verwenden — jeder Aufruf wechselt zur nächsten Farbe (default(gray) →
white → cyan → yellow → green → blue → magenta → red), sichtbar beim nächsten
Statuszeilen-Refresh.

## Deinstallieren

```sh
newsline uninstall      # stellt deine vorherige Statusleiste wieder her
```

Benötigt `bash` + `python3` (macOS / Linux; Windows über WSL).
