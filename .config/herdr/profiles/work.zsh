# herdr-up profile, sourced by ~/bin/herdr-up.
# PROFILE_SET / PROFILE_UNSET shape the server's environment, which every pane inherits.
# PROFILE_AGENT is typed into the left pane of each new workspace (empty = plain shell).
# PROFILE_DIRS are the default workspaces, labelled by directory name.
#
# Machine-specific values (like PROFILE_DIRS) go in ~/.config/herdr/profiles.local/work.zsh,
# which herdr-up sources after this file. See docs/local-overrides.md.

PROFILE_SET=(CLAUDE_CONFIG_DIR=$HOME/.claude-work)
PROFILE_UNSET=()
PROFILE_AGENT=yolo-work
PROFILE_DIRS=()
