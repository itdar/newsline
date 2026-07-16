---
description: Install & set up newsline — rotating regional news in your status line (keeps your existing status line).
---

Set up **newsline** for the user.

1. Ask the user two quick things (offer sensible defaults, don't over-ask):
   - **Language**: `ko` `ja` `en` `es` `fr` `de` `pt` `zh`, or `auto` (default: `auto`).
   - **Topic**: `general` `tech` `business` `world` `sports` `science` `health` `entertainment` (default: `general`).

2. Install to a stable location and wire the status line. It **composes with any
   existing status line** (their HUD stays visible) and hot-reloads (no restart).
   Run, substituting the chosen `<LANG>` / `<TOPIC>`:

   ```bash
   NEWSLINE_NO_INIT=1 sh "${CLAUDE_PLUGIN_ROOT}/install.sh"
   "$HOME/.local/bin/newsline" init --lang <LANG> --topic <TOPIC> --yes
   ```

3. Confirm to the user: the news line appears on their **next message** (no restart
   needed). If the command reports `python3` missing, tell them to install python3.

Notes:
- This installs the `newsline` CLI to `~/.local` (stable path), so it survives plugin
  updates. To change language/topic later: `newsline init --lang <..> --topic <..> --yes`.
- To remove: `newsline uninstall`.
