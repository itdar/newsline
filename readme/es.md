<div align="center">

[English](../README.md) · [한국어](ko.md) · [日本語](ja.md) · **Español** · [Français](fr.md) · [Deutsch](de.md) · [Português](pt.md) · [中文](zh.md)

</div>

# newsline

**¿Esperando a que Claude Code termine? Lee las últimas noticias en una línea, justo en tu barra de estado.**
Un titular regional rotativo aparece en la parte inferior de tu sesión, así una larga espera se convierte
en un vistazo rápido a las noticias. Se muestra *debajo* de tu barra de estado actual (tu HUD se mantiene).

<p align="center"><img src="../docs/demo.gif" alt="newsline — titulares regionales rotativos en la barra de estado de Claude Code" width="720"></p>

## Instalar y ejecutar — una línea

```sh
# curl (macOS / Linux / WSL) — instala y configura al instante
curl -fsSL https://raw.githubusercontent.com/itdar/newsline/master/install.sh | sh

# Homebrew
brew install itdar/tap/newsline && newsline init

# npm
npm i -g newsline-cli && newsline init

# Plugin de Claude Code — ejecútalo dentro de Claude Code y luego /newsline:setup
/plugin marketplace add itdar/newsline
/plugin install newsline@itdar
```

La línea de noticias aparece en tu **próximo mensaje**, sin reiniciar. La configuración te pregunta el
idioma y el tema, y conserva tu barra de estado actual.

## Qué hace

- **Tu equipo obtiene y muestra las noticias** — nunca toca tu código, prompts, archivos ni
  conversaciones con Claude.
- Un pequeño **servicio edge** elige las mejores fuentes regionales y enruta los clics en los titulares,
  de modo que las fuentes se mantienen actualizadas sin reinstalar. Si no está disponible, newsline
  **recurre a los feeds integrados**.
- La barra de estado es instantánea (servida desde una caché); las actualizaciones se ejecutan en
  segundo plano.

## Privacidad

Todo lo que se ejecuta en tu equipo está en este repositorio — y esta es la lista completa
de lo que sale de él:

- **Curación de feeds** (como máximo una vez por hora): `lang`, país aproximado, hora local,
  día de la semana, zona horaria, `topic` y la versión del plugin se envían al servicio edge
  para elegir fuentes regionales actualizadas. Sin ID de seguimiento, sin datos personales.
- **Clics en titulares**: los enlaces se abren a través de una pequeña redirección (ve la URL
  del artículo más `lang`/`topic`/versión), para poder reemplazar fuentes caídas en el
  servidor y contar los clics de forma agregada. No hay identificador por usuario.
- **Nunca se envía ni se lee**: tu código, prompts, archivos o conversaciones con Claude. La
  barra de estado se dibuja desde una caché local y nunca espera a la red.

**Modo totalmente local**: pon `"api": "off"` y `"endpoint": "off"` en
`~/.config/newsline/config.json` — los feeds vienen del `feeds.json` incluido y los titulares
enlazan directamente a los artículos. No se contacta con nada salvo los propios feeds.

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

## Desinstalar

```sh
newsline uninstall      # restaura tu barra de estado anterior
```

Necesita `bash` + `python3` (macOS / Linux; Windows mediante WSL).
