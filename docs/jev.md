# jevgrep (`jg`)

[jevgrep](https://github.com/dzhng/jevgrep) uses [TypeSafe's Jev](https://docs.typesafe.ai)
to find the files and source excerpts relevant to a question:
`jg "<question>" <root>`. It saves Claude Code tokens on cross-file questions in code it
doesn't know. **It is off in every project** until you opt that project in.

| Piece | What it does |
| --- | --- |
| `bin/jev-install` | Installs jevgrep at the pinned version (`JG_VERSION` and tarball checksum) into `~/.local/share/jevgrep`, saves your TypeSafe key(s) for it, and fails if it is set up for any other provider |
| `bin/jg` (`~/bin/jg`) | Wrapper Claude and you call. Enforces the opt-in, exclusions, an output cap and a timeout |
| `bin/jev-optin` | Turns a project on or off |
| `jev/skill/SKILL.md` | The skill `jev-optin` copies into a project, adapted from jevgrep's own |

## Install

1. Add your key to `~/.secrets` (see [Local overrides](local-overrides.md)):
   `export TYPESAFE_API_KEY=...`. If work projects should use a different TypeSafe account,
   add `export TYPESAFE_API_KEY_WORK=...` too.
2. Open a new shell, then run `stow .` (for `~/bin/jg` and `~/bin/jev-optin`) and `jev-install`.

## Opt a project in

```sh
jev-optin status [dir]                    # on or off, which key, and what a search may read
jev-optin on [--work|--personal] [dir]    # shows what a search may read, then asks you
jev-optin off [dir]
```

The project is the git root of `[dir]` (default: the current directory). `on` asks at your
terminal, so an agent can't opt a project in. It then:

- sets `env.JEVGREP_ENABLED` to `"1"` in the project's `.claude/settings.local.json`, which Claude
  Code keeps out of git;
- records which TypeSafe key the project uses in `env.JEVGREP_KEY`: `work` for projects under
  `$WORK_REPOS_DIR`, `personal` otherwise, unless you pass `--work` or `--personal`. Run `on`
  again with the other flag to switch; that asks too;
- copies the skill to `.claude/skills/jevgrep/`, so Claude knows to use `jg` there;
- creates `.claude/jevgrep-exclude` if it is missing.

Start a new Claude Code session afterwards. The global git ignore keeps the skill and the exclude
file out of the project's commits.

### Keep paths out

List the paths jg must never send in `.claude/jevgrep-exclude`, one gitignore pattern per line,
relative to the project root:

```text
notes/private/
*.pem
```

Run `jev-optin status` to see what a search may still read. Don't rely on a `.ignore` file for
this: jg skips an ancestor `.ignore` when the search root is a subdirectory.

## What `~/bin/jg` enforces

- **Opt-in by search root.** A search runs only when the project that contains its root has opted
  in, wherever it is started from. An opted-in session can't search another project.
- **Exclusions at any root.** It rebases the project's patterns onto whichever subdirectory is
  searched, and refuses a root that is itself excluded.
- **Nothing extra.** It refuses `--include-sensitive`, `--no-ignore` and `--hidden`, and
  `jg auth` / `jg skill`.
- **Output that fits.** It passes `--max-output-bytes 28000`, below Claude Code's ~30 KB limit
  for showing a command's output inline. Over that, Claude only sees a 2 KB preview.
- **A time limit.** It stops a search after 90 s (`JG_TIMEOUT_S`) if TypeSafe is slow.
- **The project's key.** A search uses the key the project's `JEVGREP_KEY` names, whichever
  session runs it. The work key has its own jg config and cache (`~/.config/jevgrep-work`,
  `~/.cache/jevgrep-work`). If that key isn't saved, the search refuses; it never falls back to
  the personal key.
- **TypeSafe only.** It refuses to run unless the saved credentials use the `typesafe` provider.

`jg files [root]` and `jg --help` make no requests and run anywhere.

## What gets sent to TypeSafe

The question, file paths, directory listings, file previews and verbatim source excerpts from
the search root. jg itself skips ignored, hidden, dependency, binary and `.env` files and files
that look like credentials, but that is a heuristic, not redaction. TypeSafe doesn't train on API
input, but keeps it for no fixed period; see their [legal docs](https://docs.typesafe.ai/legal.md).

## If the key is missing or TypeSafe is down

`jg` exits with an error or stops after 90 s, and Claude carries on with `rg`.

## Why not jev-pruner

[jev-pruner](https://github.com/tamaratran/jev-pruner) trims long Bash output with Jev. It was
tried and dropped (October 2026): in a benchmark it pruned nothing. It skips commands that
exit non-zero, such as a failing test run. For output Claude Code saves to a file, its result
has to fit Claude's ~2 KB preview, which a real log never did. It also sends the whole session
history with every request. `jev-install` removes it if an earlier version installed it.
