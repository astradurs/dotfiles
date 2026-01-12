
[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
eval "$(atuin init bash)"

. "$HOME/.atuin/bin/env"

[ -s "/Users/astradurs/.scm_breeze/scm_breeze.sh" ] && source "/Users/astradurs/.scm_breeze/scm_breeze.sh"

. "$HOME/.local/bin/env"
