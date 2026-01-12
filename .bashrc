
[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
eval "$(atuin init bash)"

. "$HOME/.atuin/bin/env"

[ -s "$HOME/.scm_breeze/scm_breeze.sh" ] && source "$HOME/.scm_breeze/scm_breeze.sh"

. "$HOME/.local/bin/env"
. "$HOME/.cargo/env"

eval "$(starship init bash)"
