# Guardrails

This repo is public, and it sits next to a lot of private config. Git hooks in `.githooks/`
stop secrets, personal data and unreviewed new files from being committed or pushed by
accident, whether the commit comes from you, a script or an AI agent.

## What runs when

| Check | `pre-commit` | `pre-push` |
| --- | --- | --- |
| **Secrets**: gitleaks scans the staged changes / the commits being pushed | ✓ | ✓ |
| **Email addresses** in added lines (placeholder domains like `example.com` and `*.example` are allowed) | ✓ | ✓ |
| **Blocklist**: personal strings from `~/.config/dotfiles/blocklist`, in added lines and file names | ✓ | ✓ |
| **New files** need a `y` typed at your terminal | ✓ | |

Edits to files that are already tracked only go through the scans. Adding, copying or
renaming a file into a new path also asks for approval:

```text
$ git commit
✓ no secrets (gitleaks)
✓ no personal data (emails, blocklist)
New files in this commit:
  bin/new-script
Commit these 1 new file(s)? [y/N]
```

The prompt goes to your terminal (`/dev/tty`), not to the hook's input. With no terminal,
as when an agent, a script or a GUI git client runs the commit, the answer is no:

```text
✗ 1 new file(s) need your approval: run this commit yourself in a terminal.
```

So an agent can edit tracked config and commit it, but a new file only ever lands after
you have seen its name and said yes. Have the agent stage the files, then run
`git commit` yourself.

`pre-push` checks every commit that the remote doesn't have yet. That catches commits made
with `--no-verify`, or made before the hooks were enabled.

## Setup

The hooks live in the repo, but git only runs them once this clone points at them:

```bash
git -C ~/dotfiles config core.hooksPath .githooks
```

`bin/dotfiles-bootstrap` does this for you. You also need `gitleaks`, which is in the
Brewfile. Without it, both hooks refuse to run rather than silently skipping the
secrets check.

`.githooks/` is listed in `.stow-local-ignore`, so stow doesn't link it into `~`.

## The blocklist

`~/.config/dotfiles/blocklist` holds the strings that identify you but aren't secrets, so
gitleaks can't know about them: your employer's internal project names, private project
names, account or workspace IDs. It lives outside the repo, since the list itself is
personal.

One extended regex per line, matched case-insensitively. `#` starts a comment.

```text
# Employer: internal project names
acme-internal-billing
project-falcon

# Personal projects
my-private-thing

# IDs
1234567890123
```

Keep entries specific. A common word like `admin` would block half of all commits.
Without the file, the email and secrets checks still run.

## False positives

- **One line**: add `gitleaks:allow` to the line, in a comment. Both gitleaks and the
  personal-data scan skip lines that contain it.
- **A blocklist entry that's too broad**: narrow it in `~/.config/dotfiles/blocklist`.
- **Everything, once**: `git commit --no-verify` skips `pre-commit`, but `pre-push` will
  still scan the commit. `git push --no-verify` skips that too, so treat it as a last
  resort.

## Limits

These hooks catch mistakes, not someone who is set on getting around them:

- `--no-verify`, or unsetting `core.hooksPath`, skips the hooks.
- The scans only see what is added. Something already in history stays there until the
  history is rewritten.
- The blocklist only knows what you put in it.

GitHub [secret scanning with push
protection](https://docs.github.com/en/code-security/secret-scanning/introduction/about-push-protection)
is enabled on the repo as a server-side backstop for secrets. It can't be skipped with
`--no-verify`, but it doesn't know about personal data.
