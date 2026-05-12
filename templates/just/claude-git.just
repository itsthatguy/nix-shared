# Claude Git helpers
# Import this in your project's justfile with:
#   import? ".devenv/state/nix-shared/just/claude-git.just"

# Claude-assisted git commit
[group('Git')]
commit *ARGS:
    ccommit {{ARGS}}

# Claude-assisted PR creation (interactive choice: simple or full)
[group('Git')]
pr *ARGS:
    cpr {{ARGS}}

# Simple PR generation
[group('Git')]
simple-pr *ARGS:
    cpr-simple {{ARGS}}

# Full PR generation
[group('Git')]
full-pr *ARGS:
    cpr-full {{ARGS}}
