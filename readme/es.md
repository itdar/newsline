<div align="center">

[English](../README.md) · [한국어](ko.md) · [日本語](ja.md) · **Español** · [Français](fr.md) · [Deutsch](de.md) · [Português](pt.md) · [中文](zh.md)

</div>

# newsline

**¿Esperando a que Claude Code termine? Lee las últimas noticias en una línea, justo en tu barra de estado.**
Un titular regional rotativo aparece en la parte inferior de tu sesión, así una larga espera se convierte
en un vistazo rápido a las noticias. Se muestra *debajo* de tu barra de estado actual (tu HUD se mantiene).

## Instalar y ejecutar — una línea

```sh
# curl (macOS / Linux / WSL) — instala y configura al instante
curl -fsSL https://raw.githubusercontent.com/itdar/cc-plugin/master/install.sh | sh

# Homebrew
brew install itdar/tap/newsline && newsline init

# npm
npm i -g newsline-cli && newsline init
```

La línea de noticias aparece en tu **próximo mensaje**, sin reiniciar. La configuración te pregunta el
idioma, el tema y el color del titular, y conserva tu barra de estado actual.

## Qué hace

- **Tu equipo obtiene y muestra las noticias** — nunca toca tu código, prompts, archivos ni
  conversaciones con Claude.
- Un pequeño **servicio edge** elige las mejores fuentes regionales y enruta los clics en los titulares,
  de modo que las fuentes se mantienen actualizadas sin reinstalar. Si no está disponible, newsline
  **recurre a los feeds integrados**.
- La barra de estado es instantánea (servida desde una caché); las actualizaciones se ejecutan en
  segundo plano.

## Configurar

Vuelve a ejecutar `newsline init` o edita `~/.config/newsline/config.json`:

| Clave | Predeterminado | Significado |
|---|---|---|
| `lang` | `auto` | `ko` `ja` `en` `es` `fr` `de` `pt` `zh`, o `auto` |
| `topic` | `general` | `general` `tech` `business` `world` `sports` `science` `health` `entertainment` |
| `rotate` | `6` | segundos por titular |
| `count` | `15` | titulares en rotación |
| `maxlen` | `120` | caracteres máximos (`max` = sin recorte) |
| `icon` | `📰` | icono inicial (`none` para ocultarlo) |
| `color` | `white` | color del titular: `default` `white` `cyan` `yellow` `green` `blue` `magenta` `red` |

O usa `newsline color` — cada ejecución pasa al siguiente color (default(gray) → white →
cyan → yellow → green → blue → magenta → red), visible en el próximo refresco de la
línea de estado.

## Desinstalar

```sh
newsline uninstall      # restaura tu barra de estado anterior
```

Necesita `bash` + `python3` (macOS / Linux; Windows mediante WSL).
