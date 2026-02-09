
. "$HOME/.atuin/bin/env"

. "$HOME/.local/bin/env"
. "$HOME/.cargo/env"

# Maul work config
export MAUL_REPOS_DIR="$HOME/Documents/Maul/Repos"
export MAUL_REPOS="maul-backend foodie-web kitchen-web dashboard"
export MAUL_GIT_AUTHOR="astradur@maul.is"

alias cd=z
alias maul-repos="cd $MAUL_REPOS_DIR"
alias foodie-web="cd $MAUL_REPOS_DIR/foodie-web"
alias kitchen-web="cd $MAUL_REPOS_DIR/kitchen-web"
alias maul-ad-hoc="cd $MAUL_REPOS_DIR/maul-ad-hoc"
alias maul-backend="cd $MAUL_REPOS_DIR/maul-backend"
