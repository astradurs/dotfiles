# Global Instructions

## Git / scm_breeze
This machine uses scm_breeze, which intercepts all `git` commands and breaks heredocs, subshells, and multi-arg commands.
**Always use `/usr/bin/git` instead of `git`** when running git commands via the Bash tool.
This applies to all git operations: add, commit, diff, log, status, push, etc.
