
. "$HOME/.atuin/bin/env"

. "$HOME/.local/bin/env"
. "$HOME/.cargo/env"

# work config
export WORK_REPOS_DIR="$HOME/Documents/Work/Repos"
export WORK_REPOS="backend web-app admin dashboard"
export WORK_GIT_AUTHOR="me@work.example"

alias cd=z
alias work-repos="cd $WORK_REPOS_DIR"
alias web-app="cd $WORK_REPOS_DIR/web-app"
alias admin="cd $WORK_REPOS_DIR/admin"
alias ad-hoc="cd $WORK_REPOS_DIR/ad-hoc"
alias backend="cd $WORK_REPOS_DIR/backend"
