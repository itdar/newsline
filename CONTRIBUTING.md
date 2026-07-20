# Contributing to newsline

Thanks for helping out! newsline is a small, dependency-light utility: a Bash
CLI plus a couple of Python helpers. No build step, no framework.

## Requirements

- `bash`
- `python3` (used for JSON handling and feed parsing — no `jq` needed)

That's it. There is nothing to compile.

## Project layout

| Path | What it is |
|---|---|
| `newsline` | The single CLI entrypoint (`init`, `color`, `colorlist`, `render`, `refresh`, `once`, `uninstall`). |
| `statusline.sh` | Prints the cached headline on every status-line tick. Must stay fast — never fetches. |
| `refresh.sh` | Fetches + caches headlines in the background. Holds the runtime `NEWSLINE_VERSION`. |
| `fetch.py`, `resolve.py` | Feed fetching / resolution helpers. |
| `feeds.json` | Bundled per-language feed sources. |
| `.claude-plugin/` | Claude Code plugin + marketplace manifests. |
| `dist/newsline.rb` | Homebrew formula **template** (CI fills in tag/version/sha). |
| `scripts/sync-version.sh` | Stamps one version into every file that hard-codes it. |
| `commands/` | Claude Code slash-command definitions (e.g. `/newsline:setup`). |

## Running locally

Point the CLI at throwaway config/cache/settings paths so you never touch your
real setup:

```sh
export NEWSLINE_CONFIG_DIR="$(mktemp -d)/newsline"
export NEWSLINE_CACHE="$(mktemp -d)/cache"
export NEWSLINE_SETTINGS="$(mktemp -d)/settings.json"

./newsline init --yes        # non-interactive setup
./newsline once              # fetch + print headlines once
./newsline colorlist         # preview the color palette
./newsline render            # what Claude Code runs each tick
```

Handy overrides while testing:

- `NEWSLINE_NOW=<epoch>` — freeze the clock (headline rotation is time-based).
- `NEWSLINE_FORCE_TTY=1` — force interactive prompts even without a TTY.
- `NEWSLINE_TTL=0` — always treat the cache as stale.

Before sending a change, at least run `bash -n newsline` (and `bash -n` on any
other script you touched) to catch syntax errors.

## Versioning & releasing

The version lives in **one place — `package.json`** — and a script stamps it
into every other file that hard-codes it. You never edit those by hand.

### The four files that carry the version

| File | Field | Used by |
|---|---|---|
| `package.json` | `version` | the npm package (`npm i -g newsline-cli`); the source of truth |
| `.claude-plugin/plugin.json` | `version` | the Claude Code **plugin** manifest |
| `.claude-plugin/marketplace.json` | `plugins[].version` | the Claude Code **marketplace** listing |
| `refresh.sh` | `NEWSLINE_VERSION` | runtime self-report → server "update available" nudge |

> `marketplace.json` also has a `metadata.version` field — that is the
> marketplace's *own* version and is **independent**; the sync script never
> touches it.
>
> `dist/newsline.rb` (Homebrew) is **not** in this list: CI fills its version
> in from the git tag at release time.

### Cutting a release

Example: releasing `1.0.2`.

```sh
# 1. make your code/doc changes as usual

# 2. stamp the new version into all four files at once
./scripts/sync-version.sh 1.0.2

# 3. commit everything together
git add -A
git commit -m "1.0.2: <what changed>"

# 4. tag with the SAME version, prefixed with v
git tag v1.0.2

# 5. push commit + tag — this triggers the release workflows
git push --follow-tags
```

The git tag (`vX.Y.Z`) **must match** the version in the files. CI enforces this
and will fail the release if `refresh.sh`'s `NEWSLINE_VERSION` doesn't match the
tag. Because both come from the single number you pass to `sync-version.sh` and
`git tag`, they stay consistent.

Re-sync any time without releasing (e.g. to fix drift): running
`./scripts/sync-version.sh` with no argument re-stamps every file from
`package.json`'s current version.

> Shortcut: `npm version patch` (or `minor` / `major` / an explicit `1.0.2`)
> does steps 2–4 in one command — it bumps `package.json`, runs the same sync
> via an npm hook, commits all four files, and creates the `vX.Y.Z` tag. Then
> just `git push --follow-tags`. It requires a clean working tree, so commit any
> code changes first.

### What CI does on a `v*` tag

Two GitHub Actions run automatically (`.github/workflows/`):

- **`npm.yml`** — validates `refresh.sh` matches the tag, then publishes the
  package to npm.
- **`homebrew.yml`** — validates the same, renders `dist/newsline.rb` from the
  tag, and pushes the updated formula to `itdar/homebrew-tap`.

After pushing, check the **Actions** tab: both workflows should be green. A red
build almost always means the tag and the file versions disagree.

## License

By contributing you agree that your contributions are licensed under the
project's [MIT License](LICENSE).
