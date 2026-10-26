# Dotfiles

My personal macOS configuration files, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Contents

This repository contains configuration files for:

- **Shell**: `.zshrc`, `.bashrc`, `.profile`
- **Vim**: `.vimrc`
- **Git**: `.gitconfig` (with separate local config for personal info)
- **Alacritty**: Terminal emulator configuration (window around Herdr)
- **Fish**: Fish shell configuration
- **Atuin**: Shell history sync
- **GitHub CLI**: `gh` configuration
- **Neofetch**: System information tool
- **Spotify Player**: Terminal Spotify client
- **Taskwarrior**: Task management with custom UDAs and reports ([docs](docs/taskwarrior.md))
- **jevgrep**: `jg`, a TypeSafe Jev code search for Claude Code, off until a project opts in ([docs](docs/jev.md))

## Prerequisites

- **macOS** (these configs are tailored for macOS)
- **Homebrew**: [Install here](https://brew.sh/)
- **GNU Stow**: Install with `brew install stow`

## Installation

### First Time Setup

1. **Clone this repository to your home directory:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Set up Git personal information:**

   Create `~/.gitconfig.local` with your personal Git information:
   ```bash
   cat > ~/.gitconfig.local << EOF
   [user]
       name = Your Name
       email = your.email@example.com
   EOF
   ```

   Personal, work-specific and secret settings all go in local drop-in files like this one.
   See [Local overrides](docs/local-overrides.md) for the full list.

3. **Backup existing dotfiles (important!):**
   ```bash
   # Back up any existing config files you want to keep
   mkdir -p ~/dotfiles-backup
   mv ~/.zshrc ~/dotfiles-backup/ 2>/dev/null || true
   mv ~/.gitconfig ~/dotfiles-backup/ 2>/dev/null || true
   # ... backup other files as needed
   ```

4. **Use GNU Stow to create symlinks:**
   ```bash
   cd ~/dotfiles
   stow .
   ```

   This will create symlinks in your home directory (`~`) pointing to the files in `~/dotfiles`.

### Verify Installation

Check that symlinks were created correctly:
```bash
ls -la ~ | grep "\->"
ls -la ~/.config/ | grep "\->"
```

You should see symlinks pointing to files in your `dotfiles` directory.

## Usage

### Adding New Dotfiles

1. Copy the config file to the dotfiles repo:
   ```bash
   cp ~/.someconfig ~/dotfiles/.someconfig
   ```

2. Remove the original and restow:
   ```bash
   rm ~/.someconfig
   cd ~/dotfiles
   stow .
   ```

3. Commit the changes:
   ```bash
   git add .someconfig
   git commit -m "Add .someconfig"
   git push
   ```

### Updating Dotfiles

Since the files are symlinked, any changes you make to your config files are automatically reflected in the repository. Just commit and push:

```bash
cd ~/dotfiles
git add -u
git commit -m "Update configuration"
git push
```

### Setting Up on a New Machine

1. Clone the repository
2. Install GNU Stow
3. Set up `.gitconfig.local` with your personal info
4. Run `stow .` from the dotfiles directory
5. Add whichever [local drop-ins](docs/local-overrides.md) the machine needs (`~/.secrets`, `~/.profile.local`, ...)
6. Enable the [guardrails](docs/guardrails.md): `git config core.hooksPath .githooks`

### Removing Dotfiles

To remove all symlinks created by Stow:
```bash
cd ~/dotfiles
stow -D .
```

## How GNU Stow Works

GNU Stow creates symlinks from the parent directory to the files in the stow directory. When you run `stow .` from `~/dotfiles`, it:

1. Looks at the directory structure in `~/dotfiles`
2. Creates symlinks in the parent directory (`~`) for each file
3. Preserves the directory structure (e.g., `.config/alacritty/` → `~/.config/alacritty/`)

This means:
- `~/dotfiles/.zshrc` → symlinked as `~/.zshrc`
- `~/dotfiles/.config/fish/` → symlinked as `~/.config/fish/`

## Important Notes

### Git Configuration

This repository uses a split Git configuration:
- `.gitconfig` (tracked): Contains global Git settings
- `.gitconfig.local` (not tracked): Contains personal information (name, email)

Always set up `.gitconfig.local` on new machines with your personal information.

### Local Overrides

This repo is public. Anything personal, work-specific or secret lives in untracked drop-in
files that the tracked config loads if they exist: `~/.profile.local`, `~/.zshrc.local`,
`~/.bashrc.local`, `~/.secrets`, `~/.gitconfig.local`, `~/.config/daily-report/repos` and
`~/.config/herdr/profiles.local/`. See [docs/local-overrides.md](docs/local-overrides.md) for
what goes where, the load order, and examples.

### Guardrails

Git hooks in `.githooks/` scan every commit and push for secrets (gitleaks), email addresses
and personal strings from a local blocklist, and ask for your OK at the terminal before any
new file is committed. Enable them on each clone with
`git config core.hooksPath .githooks` (`bin/dotfiles-bootstrap` does this). See
[docs/guardrails.md](docs/guardrails.md).

### Sensitive Files

The `.gitignore` is configured to exclude:
- `*.local` drop-ins and `.secrets` (see [Local overrides](docs/local-overrides.md))
- SSH keys
- Shell history files
- Credentials and secrets
- OS-generated files

Never commit sensitive information to this repository.

## Troubleshooting

### Stow Conflicts

If Stow reports conflicts:
```
WARNING! stowing . would cause conflicts:
  * existing target is not owned by stow: .zshrc
```

This means a file already exists. You need to:
1. Back up the existing file
2. Remove it
3. Run `stow .` again

### Symlink Issues

To see what Stow would do without making changes:
```bash
stow -n .  # dry run
stow -v .  # verbose mode
```

## License

Feel free to use these configurations as inspiration for your own dotfiles!
