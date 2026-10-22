# Local overrides

This repo is public, so it only holds config that is safe and useful on any machine.
Anything personal, work-specific or secret goes in a **local drop-in**: a file that lives
outside the repo, that git never sees, and that the tracked config picks up if it exists.

Every hook is optional. A fresh machine works without any of these files; you add the ones
you need.

## The drop-ins

| File | Loaded by | Use it for |
| --- | --- | --- |
| `~/.profile.local` | end of `.profile` (so both zsh and bash) | env vars and aliases shared by both shells: work paths, project `cd` aliases, your work git author |
| `~/.zshrc.local` | last line of `.zshrc` | zsh-only settings, and anything that must override what `.zshrc` sets |
| `~/.bashrc.local` | last line of `.bashrc` | bash-only settings |
| `~/.secrets` | `.zshrc`, before `.profile` | tokens and API keys (`export ASANA_PAT=...`). Keep it `chmod 600` |
| `~/.gitconfig.local` | `[include]` in `.gitconfig` | git `user.name` / `user.email`, credential helpers, per-machine git settings |
| `~/.config/daily-report/repos` | `bin/daily-report` | which repos the daily report scans |
| `~/.config/herdr/profiles.local/<name>.zsh` | `bin/herdr-up`, after `profiles/<name>.zsh` | the workspaces a Herdr profile opens, or a whole machine-only profile |
| `~/.config/dotfiles/blocklist` | `.githooks/` (pre-commit, pre-push) | personal strings that must never be committed; see [guardrails](guardrails.md) |

Load order for an interactive zsh: `~/.secrets` → `~/.profile` → `~/.profile.local` → rest of
`.zshrc` → `~/.zshrc.local`. Later files win.

## Rules of thumb

- **Is it secret?** Put it in `~/.secrets` (shell) or `~/.gitconfig.local` (git).
- **Does it name a person, employer, client, or private project?** Put it in a `.local` file.
- **Is it a path that only exists on this machine?** Put it in a `.local` file.
- **Would it help on any machine?** Commit it to the repo.

`.gitignore` ignores `*.local`, `.secrets` and the local config directories as a safety net,
in case one of them is ever created inside the repo by mistake. Don't rely on that: keep
drop-ins in `~` and `~/.config`, never in `~/dotfiles`.

Stow note: `~/.config/herdr/profiles` is a symlink into this repo, so anything written there
lands in the repo. That is why local Herdr profiles go in the sibling `profiles.local/`
directory, which is a real directory in `~/.config/herdr`.

## Examples

### `~/.profile.local`

```sh
# Work config
export WORK_REPOS_DIR="$HOME/Documents/Work/Repos"
export WORK_GIT_AUTHOR="me@work.example"

alias work-repos="cd $WORK_REPOS_DIR"
alias backend="cd $WORK_REPOS_DIR/live/backend"
```

### `~/.zshrc.local`

```sh
# Asana workspace for ~/bin/task-sync-asana (the token itself goes in ~/.secrets)
export ASANA_WORKSPACE_GID="1234567890"
```

### `~/.secrets`

```sh
export ASANA_PAT="..."
```

Create it with `install -m 600 /dev/null ~/.secrets` so it is never world-readable.

### `~/.config/daily-report/repos`

One repo name per line. `#` starts a comment. `bin/daily-report` looks for each name
directly under `$WORK_REPOS_DIR`, then one level down (e.g. `Repos/live/<name>`).

```text
# Active work repos
backend
web-app
admin
```

Without this file, `daily-report` scans every git repo it finds under `$WORK_REPOS_DIR` and
one level down. The commit author comes from `$WORK_GIT_AUTHOR`, or `git config user.email`
if that is unset.

### `~/.config/herdr/profiles.local/work.zsh`

`herdr-up work` sources `~/.config/herdr/profiles/work.zsh` (tracked) and then this file,
so anything set here overrides the tracked profile. The tracked profiles leave
`PROFILE_DIRS` empty, so this is where your default workspaces go.

```zsh
PROFILE_DIRS=(
  ~/Documents/Work/Repos/live/backend
  ~/Documents/Work/Repos/live/web-app
)
```

A profile that exists only in `profiles.local/` works too, e.g. `profiles.local/client.zsh`
for `herdr-up client`. See the comments in `.config/herdr/profiles/work.zsh` for every field.

## New machine checklist

After `stow .`:

1. `~/.gitconfig.local` with your name and email (see the README).
2. `install -m 600 /dev/null ~/.secrets` and add your tokens.
3. Any of the other drop-ins above that this machine needs.
4. `~/.config/dotfiles/blocklist` with the personal strings to keep out of the repo.

## Adding a new hook

When a tracked file needs a machine-specific value:

1. Source or read an optional file, and do nothing if it is missing:
   `[[ -f ~/.foo.local ]] && source ~/.foo.local`. For a script's own config, use
   `${XDG_CONFIG_HOME:-$HOME/.config}/<script>/`.
2. Give the tracked file a sensible default, or a clear error if the value is required.
3. Add the file to the table above, with an example.
4. If it could ever end up inside the repo, add it to `.gitignore`.
5. If the value identifies you (an employer, a project, an ID), add it to
   `~/.config/dotfiles/blocklist` so the [guardrails](guardrails.md) catch it if it ever leaks back in.
