# Shared checks for the pre-commit and pre-push hooks. Sourced, not run. See docs/guardrails.md.

# Personal strings that must never be committed: one extended regex per line, '#' comments,
# matched case-insensitively. Lives outside the repo, since the list itself is personal.
BLOCKLIST="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/blocklist"

fail() { printf '\033[31m✗ %s\033[0m\n' "$*" >&2; }
ok() { printf '\033[32m✓ %s\033[0m\n' "$*" >&2; }

require_gitleaks() {
    command -v gitleaks >/dev/null && return 0
    fail "gitleaks is not installed (brew install gitleaks); refusing to skip the secrets check."
    return 1
}

# Reads a -U0 unified diff on stdin and prints "<where><TAB><text>" for every added line, plus one
# "<path> (file name)<TAB><path>" entry per file, so paths are checked as well as contents.
added_lines() {
    awk '
        /^\+\+\+ / { file = substr($0, 7); if ($0 != "+++ /dev/null") print file " (file name)\t" file; next }
        /^@@/ { match($0, /\+[0-9]+/); line = substr($0, RSTART + 1, RLENGTH - 1); next }
        /^\+/ { print file ":" line "\t" substr($0, 2); line++ }
    '
}

# Reads a -U0 unified diff on stdin. Fails on added email addresses and blocklist matches.
# A line containing "gitleaks:allow" is skipped, the same marker gitleaks honours.
scan_personal() {
    local lines emails blocked status=0
    lines=$(added_lines | grep -v 'gitleaks:allow')

    # Emails, except placeholder ones that docs and examples may use freely.
    emails=$(printf '%s\n' "$lines" | awk -F '\t' '{
        text = substr($0, index($0, "\t") + 1); t = tolower(text)
        while (match(t, /[a-z0-9._%+-]+@[a-z0-9-]+(\.[a-z0-9-]+)*\.[a-z][a-z]+/)) {
            e = substr(t, RSTART, RLENGTH); t = substr(t, RSTART + RLENGTH)
            if (e !~ /@(([a-z0-9-]+\.)*example(\.(com|org|net))?|users\.noreply\.github\.com)$/) { print "  " $1 ": " text; next }
        }
    }')
    if [ -n "$emails" ]; then
        fail "email address(es) in added lines:"
        printf '%s\n' "$emails" >&2
        status=1
    fi

    # awk regexes are EREs, so blocklist lines behave as they would in grep -iE.
    blocked=$(printf '%s\n' "$lines" | awk -F '\t' -v list="$BLOCKLIST" '
        BEGIN { while ((getline p < list) > 0) if (p !~ /^[[:space:]]*(#|$)/) pats[++n] = tolower(p) }
        {
            text = substr($0, index($0, "\t") + 1); t = tolower(text)
            for (i = 1; i <= n; i++) if (t ~ pats[i]) { print "  " $1 ": " text; break }
        }
    ')
    if [ -n "$blocked" ]; then
        fail "blocklisted personal string(s) (from $BLOCKLIST):"
        printf '%s\n' "$blocked" >&2
        status=1
    fi

    [ $status -eq 0 ] && ok "no personal data (emails, blocklist)"
    return $status
}
