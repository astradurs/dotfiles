# Global Agent Instructions

## Herdr review gate

Applies when running inside Herdr (`HERDR_ENV=1` is set) and the `review_changes` tool from the herdr-file-annotator MCP server is available.

Before marking any task complete, call the `review_changes` tool and act on the returned annotations. Do not proceed on a `request_changes` or `reject` verdict without addressing the feedback.
