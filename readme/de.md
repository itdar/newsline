<div align="center">

[English](../README.md) · [한국어](ko.md) · [日本語](ja.md) · [Español](es.md) · [Français](fr.md) · **Deutsch** · [Português](pt.md) · [中文](zh.md)

</div>

# newsline

**Wartest du darauf, dass Claude Code fertig wird? Lies die neuesten Ein-Zeilen-News direkt in deiner Statusleiste.**
Eine rotierende regionale Schlagzeile sitzt am unteren Rand deiner Sitzung – so wird aus langem Warten
ein schneller Blick in die Nachrichten. Sie erscheint *unter* deiner bestehenden Statusleiste (dein HUD
bleibt erhalten).

<p align="center"><img src="../docs/demo.gif" alt="newsline — rotierende regionale Schlagzeilen in der Claude-Code-Statusleiste" width="720"></p>

## Installieren & starten — eine Zeile

```sh
# curl (macOS / Linux / WSL) — installiert und richtet sofort ein
curl -fsSL https://raw.githubusercontent.com/itdar/newsline/master/install.sh | sh

# Homebrew
brew install itdar/tap/newsline && newsline init

# npm
npm i -g newsline-cli && newsline init

# Claude-Code-Plugin — in Claude Code ausführen, danach /newsline:setup
/plugin marketplace add itdar/newsline
/plugin install newsline@itdar
```

Die News-Zeile erscheint bei deiner **nächsten Nachricht** – kein Neustart nötig. Die Einrichtung fragt
nach Sprache und Thema und behält deine bestehende Statusleiste bei.

## Was es macht

- **Dein Rechner holt und zeigt die Nachrichten** – er rührt niemals deinen Code, deine Prompts, Dateien
  oder Claude-Unterhaltungen an.
- Ein kleiner **Edge-Dienst** wählt die besten regionalen Quellen aus und leitet Klicks auf Schlagzeilen
  weiter, sodass die Quellen ohne Neuinstallation aktuell bleiben. Ist er nicht erreichbar, **greift
  newsline auf die integrierten Feeds zurück**.
- Die Statusleiste ist sofort da (aus einem Cache); Aktualisierungen laufen im Hintergrund.

## Datenschutz

Alles, was auf deinem Rechner läuft, steht in diesem Repository — und das ist die
vollständige Liste dessen, was ihn je verlässt:

- **Feed-Kuratierung** (höchstens einmal pro Stunde): `lang`, grobes Land, Ortszeit,
  Wochentag, Zeitzone, `topic` und die Plugin-Version gehen an den Edge-Dienst, damit er
  aktuelle regionale Quellen auswählen kann. Keine Tracking-ID, keine persönlichen Daten.
- **Klicks auf Schlagzeilen**: Links öffnen sich über eine kleine Weiterleitung (sie sieht
  die Artikel-URL plus `lang`/`topic`/Version), damit tote Quellen serverseitig ersetzt und
  Klicks aggregiert gezählt werden können. Es gibt keine nutzerbezogene Kennung.
- **Nie gesendet, nie gelesen**: dein Code, deine Prompts, Dateien oder
  Claude-Unterhaltungen. Die Statusleiste wird aus einem lokalen Cache gezeichnet und wartet
  nie auf das Netzwerk.

**Vollständig lokaler Modus**: setze `"api": "off"` und `"endpoint": "off"` in
`~/.config/newsline/config.json` — die Feeds kommen aus der mitgelieferten `feeds.json`, und
Schlagzeilen verlinken direkt auf die Artikel. Außer den Feeds selbst wird nichts kontaktiert.

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

## Deinstallieren

```sh
newsline uninstall      # stellt deine vorherige Statusleiste wieder her
```

Benötigt `bash` + `python3` (macOS / Linux; Windows über WSL).
