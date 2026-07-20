<div align="center">

[English](../README.md) · [한국어](ko.md) · [日本語](ja.md) · [Español](es.md) · **Français** · [Deutsch](de.md) · [Português](pt.md) · [中文](zh.md)

</div>

# newsline

**En attendant que Claude Code termine ? Lisez l'actualité en une ligne, directement dans votre barre d'état.**
Un titre régional défile en bas de votre session : une longue attente se transforme en un coup d'œil
rapide à l'actualité. Il s'affiche *sous* votre barre d'état existante (votre HUD reste en place).

<p align="center"><img src="../docs/demo.gif" alt="newsline — titres régionaux défilants dans la barre d'état de Claude Code" width="720"></p>

## Installer et lancer — une ligne

```sh
# curl (macOS / Linux / WSL) — installe et configure immédiatement
curl -fsSL https://raw.githubusercontent.com/itdar/newsline/master/install.sh | sh

# Homebrew
brew install itdar/tap/newsline && newsline init

# npm
npm i -g newsline-cli && newsline init

# Plugin Claude Code — à lancer dans Claude Code, puis /newsline:setup
/plugin marketplace add itdar/newsline
/plugin install newsline@itdar
```

La ligne d'actualité apparaît dès votre **prochain message** — sans redémarrage. La configuration vous
demande une langue, un thème et une couleur de titre, et conserve votre barre d'état existante.

## Ce que ça fait

- **Votre machine récupère et affiche l'actualité** — elle ne touche jamais à votre code, vos prompts,
  vos fichiers ni vos conversations avec Claude.
- Un petit **service edge** sélectionne les meilleures sources régionales et route les clics sur les
  titres, afin que les sources restent à jour sans réinstallation. S'il est injoignable, newsline
  **bascule sur les flux intégrés**.
- La barre d'état est instantanée (servie depuis un cache) ; les rafraîchissements s'exécutent en
  arrière-plan.

## Confidentialité

Tout ce qui s'exécute sur votre machine se trouve dans ce dépôt — et voici la liste complète
de ce qui en sort :

- **Curation des flux** (au plus une fois par heure) : `lang`, pays approximatif, heure
  locale, jour de la semaine, fuseau horaire, `topic` et la version du plugin sont envoyés au
  service edge pour choisir des sources régionales à jour. Pas d'ID de suivi, pas de données
  personnelles.
- **Clics sur les titres** : les liens s'ouvrent via une petite redirection (elle voit l'URL
  de l'article plus `lang`/`topic`/version), afin de remplacer côté serveur les sources mortes
  et de compter les clics de façon agrégée. Aucun identifiant par utilisateur.
- **Jamais envoyé, jamais lu** : votre code, vos prompts, vos fichiers ou vos conversations
  avec Claude. La barre d'état s'affiche depuis un cache local et n'attend jamais le réseau.

**Mode entièrement local** : mettez `"api": "off"` et `"endpoint": "off"` dans
`~/.config/newsline/config.json` — les flux viennent du `feeds.json` embarqué et les titres
pointent directement vers les articles. Rien d'autre que les flux eux-mêmes n'est contacté.

## Configurer

Relancez `newsline init`, ou modifiez `~/.config/newsline/config.json` :

| Clé | Par défaut | Signification |
|---|---|---|
| `lang` | `auto` | `ko` `ja` `en` `es` `fr` `de` `pt` `zh`, ou `auto` |
| `topic` | `general` | `general` `tech` `business` `world` `sports` `science` `health` `entertainment` |
| `rotate` | `6` | secondes par titre |
| `count` | `15` | titres en rotation |
| `maxlen` | `120` | caractères maximum (`max` = sans coupure) |
| `icon` | `📰` | icône de tête (`none` pour masquer) |
| `color` | `white` | couleur du titre : `default` `white` `cyan` `yellow` `green` `blue` `magenta` `red` |

Ou utilisez `newsline color` — chaque exécution passe à la couleur suivante (default(gray) →
white → cyan → yellow → green → blue → magenta → red), visible au prochain
rafraîchissement de la ligne d'état.

## Désinstaller

```sh
newsline uninstall      # restaure votre barre d'état précédente
```

Nécessite `bash` + `python3` (macOS / Linux ; Windows via WSL).
