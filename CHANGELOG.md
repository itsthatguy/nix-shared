# Changelog

## v2.1.1 (2026-05-14)

### Features
- run plugin setup scripts sequentially


## v2.1.0 (2026-05-14)

### Features
- add plugin cleanup with state tracking
- add chrome-devtools Claude Code plugin module

### Refactoring
- simplify test matrix to single integration test
- consolidate ollama stubs into tests/lib/stubs.nix
- use Claude Code plugin with devenv task


## v2.0.2 (2026-05-12)

### Fixes
- scope LD_LIBRARY_PATH to chunkhound wrapper only
- add native deps for Linux ML dependencies


## v2.0.1 (2026-05-12)

### Features
- add Git group to claude-git recipes


## v2.0.0 (2026-05-12)

### Features
- add devenv module for claude-assisted git workflows

### Other
- refactor!: namespace module options under nix-shared and reorganize templates


## v1.0.1 (2026-05-11)

### Features
- default to externally installed ollama
- create GitHub release with changelog via gh CLI

### Refactoring
- split into PR-based prepare and publish workflows

### Other
- revert: restore simple release workflow


## v1.0.0 (2026-05-10)

### Features
feat: add release script with semantic versioning and changelog generation
feat(devenv): add grepika code search module

### Fixes
fix(flake): compose overlays.default as a function
fix(chunkhound): use PATH ollama instead of pkgs.ollama in scripts
fix(chunkhound): set database path at runtime instead of nix eval time

### Refactoring
refactor(chunkhound): consolidate state files into dedicated subdirectory

### Other
- Merge pull request #2 from itsthatguy/feat/release-script
- Merge pull request #1 from kevrom/fix/chunkhound-ollama-unconditional-ref
- add friendly error when chunkhound daemon holds db lock
- fix chunkhound script to show help when no args passed
- add chunkhound devenv module
- update readme
- initial overlay code
