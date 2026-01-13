
# Source shared profile (aliases, etc.)
[[ -f ~/.profile ]] && source ~/.profile

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
eval "$(atuin init bash)"

. "$HOME/.atuin/bin/env"

[ -s "/Users/astradurs/.scm_breeze/scm_breeze.sh" ] && source "/Users/astradurs/.scm_breeze/scm_breeze.sh"

. "$HOME/.local/bin/env"
. "$HOME/.cargo/env"

eval "$(starship init bash)"
