#!/usr/bin/env bash
# Single-source version sync. The version lives in package.json; this stamps it
# into every other file that hard-codes it, so you never edit them by hand.
#
#   npm version 1.2.3    # bumps package.json, auto-runs this, commits + tags v1.2.3
#   git push --follow-tags   # -> triggers the npm + homebrew release workflows
#
# Standalone (no npm):
#   ./scripts/sync-version.sh          # re-sync everything to package.json's version
#   ./scripts/sync-version.sh 1.2.3    # set an explicit version everywhere
#
# Files kept in lockstep: package.json, .claude-plugin/plugin.json,
# .claude-plugin/marketplace.json (plugin entry only), refresh.sh (NEWSLINE_VERSION).
set -eu
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

python3 - "${1:-}" <<'PY'
import re, sys

ver = sys.argv[1].strip()
if not ver:  # no arg: package.json is the source of truth
    m = re.search(r'"version"\s*:\s*"([^"]+)"', open("package.json").read())
    if not m:
        sys.stderr.write("sync-version: no version in package.json\n"); sys.exit(1)
    ver = m.group(1)

def stamp(path, pattern):
    s = open(path).read()
    new, n = re.subn(pattern, lambda m: m.group(1) + ver + m.group(2), s, count=1)
    if n == 0:
        sys.stderr.write("sync-version: no version stamp found in %s\n" % path); sys.exit(1)
    if new != s:
        open(path, "w").write(new); print("  set %-32s -> %s" % (path, ver))
    else:
        print("  ok  %-32s    %s" % (path, ver))

VER = r'("version"\s*:\s*")[^"]*(")'
stamp("package.json", VER)
stamp(".claude-plugin/plugin.json", VER)
# marketplace.json has two "version" fields; only the one inside "plugins" is ours
stamp(".claude-plugin/marketplace.json",
      r'("plugins"\s*:\s*\[[\s\S]*?"version"\s*:\s*")[^"]*(")')
# refresh.sh: export NEWSLINE_VERSION="${NEWSLINE_VERSION:-X.Y.Z}"
stamp("refresh.sh", r'(NEWSLINE_VERSION:-)[^}"]*(})')

print("newsline version synced to %s" % ver)
PY
