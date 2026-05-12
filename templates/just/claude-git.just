# Claude Git helpers
# Import this in your project's justfile with:
#   import? ".devenv/state/nix-shared/just/claude-git.just"

# Claude-assisted git commit
commit *ARGS:
    ccommit {{ARGS}}

# Claude-assisted PR creation (interactive choice: simple or full)
pr *ARGS:
    cpr {{ARGS}}

# Simple PR generation
simple-pr *ARGS:
    cpr-simple {{ARGS}}

# Full PR generation
full-pr *ARGS:
    cpr-full {{ARGS}}
