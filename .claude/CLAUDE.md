# Global Instructions

## Herdr review gate

Applies when running inside Herdr (`HERDR_ENV=1` is set) and the Annotate plugin is installed
(`herdr plugin list` shows `annotate`).

Use the `review-changes` skill to hand work over for line-by-line annotation. Open a review:

- when asked to review changes, review the diff, or annotate something,
- before reporting a code task complete,
- before committing, when a commit was requested.

The review does not block. Open the pane, say in a sentence or two what changed, and end the
turn — the feedback arrives as the next user message, as numbered line-anchored items. Never
poll the pane, and never treat silence as approval. Address every returned item before
reporting the task complete or committing.

Skip the review for turns that changed no tracked file.

## jevgrep (`jg`)

`jg` works only in projects that opt in, and those are the projects where the `jevgrep` skill is
available. If the skill isn't loaded in this session, don't run `jg`. Where it is, use
`jg "<question>" <root>` first for behaviour questions whose answer likely spans several files in
code you don't know yet, such as "where is X handled?" or "how does Y reach Z?". Use `rg` or a
direct read for exact symbols, strings and file names, and for small repos. Pass the narrowest
root that answers the question. If `jg` refuses, fails or reports incomplete results, carry on
with `rg` and don't retry.
