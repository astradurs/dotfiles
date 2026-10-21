
. "$HOME/.atuin/bin/env"

. "$HOME/.local/bin/env"
. "$HOME/.cargo/env"

alias cd=z

# Machine-local env and aliases (work config, project shortcuts). Not tracked; see docs/local-overrides.md.
[[ -f ~/.profile.local ]] && source ~/.profile.local
