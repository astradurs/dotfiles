# Taskwarrior Setup

Taskwarrior is configured via `~/.taskrc` (symlinked from dotfiles) with custom UDAs for repo linking and Asana sync, a project hierarchy, and custom reports.

## UDA Reference

| Field | Type | Values | Purpose |
|---|---|---|---|
| `repo` | string | any | Git repo path, e.g. `myorg/myrepo` |
| `asana_gid` | string | any | Asana task ID for sync tracking |
| `source` | string | `asana`, `manual`, `github` | Where the task originated |

## Project Hierarchy

Tasks use a dot-separated hierarchy:

| Prefix | Example | Use |
|---|---|---|
| `work.<project>` | `work.maul-backend`, `work.foodie-web`, `work.kitchen-web`, `work.dashboard` | Work projects |
| `personal.<project>` | `personal.dotfiles`, `personal.homelab` | Personal projects |
| `side.<project>` | `side.myapp` | Side projects |

Tasks without a project land in the **inbox** report for triage.

## Custom Reports

| Report | Command | What it shows |
|---|---|---|
| `work` | `task work` | All pending tasks under `project:work` |
| `asana` | `task asana` | All tasks with `source:asana` |
| `byrepo` | `task byrepo` | Tasks grouped by `repo` UDA |
| `inbox` | `task inbox` | Tasks with no project (triage queue) |

## Quick-Start Usage

### Adding tasks

```bash
# Simple task
task add "Review PR for auth changes"

# With project and repo
task add "Fix login timeout" project:work.maul-backend repo:maul/maul-backend source:manual

# Personal task
task add "Update neovim config" project:personal.dotfiles

# Side project
task add "Add dark mode" project:side.myapp repo:astradurs/myapp
```

### Filtering

```bash
# All work tasks
task work

# Tasks for a specific project
task project:work.maul-backend list

# Tasks from Asana
task asana

# Tasks linked to a specific repo
task repo:maul/maul-backend list

# Inbox (needs triage)
task inbox
```

### Managing tasks

```bash
# Complete a task
task <ID> done

# Modify a task
task <ID> modify project:work.foodie-web

# Add a repo to an existing task
task <ID> modify repo:myorg/myrepo

# Delete a task
task <ID> delete

# View task details
task <ID> info
```

## Asana Sync Setup

The sync uses [syncall](https://github.com/bergercookie/syncall) to bidirectionally sync Taskwarrior with Asana.

### Prerequisites

1. **Asana Personal Access Token (PAT)**
   - Go to <https://app.asana.com/0/developer-console>
   - Create a new PAT
   - Export it: `export ASANA_PAT=<your-token>`

2. **Workspace GID**
   - Find it via the Asana API: `curl -H "Authorization: Bearer $ASANA_PAT" https://app.asana.com/api/1.0/workspaces`
   - Export it: `export ASANA_WORKSPACE_GID=<your-gid>`

3. **Install syncall**
   ```bash
   uv pip install 'syncall[asana,tw]'
   ```

### Running sync

```bash
# Full sync
tw_asana_sync \
  --taskwarrior-tags asana \
  --asana-workspace-gid "$ASANA_WORKSPACE_GID" \
  --asana-token "$ASANA_PAT"

# Dry run (preview changes)
tw_asana_sync \
  --taskwarrior-tags asana \
  --asana-workspace-gid "$ASANA_WORKSPACE_GID" \
  --asana-token "$ASANA_PAT" \
  --dry-run

# Sync specific project only
tw_asana_sync \
  --taskwarrior-tags asana \
  --asana-workspace-gid "$ASANA_WORKSPACE_GID" \
  --asana-project-gid "<PROJECT_GID>" \
  --asana-token "$ASANA_PAT"
```

Or use the scaffold script: `task-sync-asana` (in `~/bin/`).

## taskwarrior-tui Keybindings

Launch with `taskwarrior-tui`.

| Key | Action |
|---|---|
| `j` / `k` | Move down / up |
| `J` / `K` | Move to bottom / top |
| `a` | Add task |
| `d` | Complete (done) task |
| `x` | Delete task |
| `m` | Modify task |
| `e` | Edit task (opens `$EDITOR`) |
| `u` | Undo last action |
| `l` | Toggle log view |
| `t` | Toggle tag filter |
| `/` | Filter tasks |
| `!` | Shell command |
| `1`-`9` | Switch between reports |
| `q` | Quit |
| `?` | Help |

## File Locations

| File | Purpose |
|---|---|
| `~/.taskrc` | Configuration (symlink to dotfiles) |
| `~/.task/` | Data directory (local, not tracked in git) |
| `~/bin/task-sync-asana` | Asana sync scaffold script |
