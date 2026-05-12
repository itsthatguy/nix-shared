# Claude Git Helpers devenv module
#
# Usage in devenv.yaml:
#   inputs:
#     nix-shared:
#       url: github:itsthatguy/nix-shared
#
#   imports:
#     - nix-shared/modules/devenv/claude-git.nix
#
# Usage in devenv.nix:
#   {
#     claude-git.enable = true;
#   }
#
# Provides:
#   - ccommit: Claude-assisted git commit (generates conventional commit message)
#   - cpr: Claude-assisted PR creation (choose between full or simple)
#   - cpr-full: Full PR generation
#   - cpr-simple: Simple PR generation
#
# Dependencies:
#   - claude: Must be in PATH (install via home-manager, brew, npm, etc.)
#   - gh, gum: Installed via this module

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.claude-git;

  rawOutput = "You are a raw text generator. Output ONLY the content specified by the skill template. Do not add any text before or after. No introductions, no summaries, no questions, no commentary.";

  ccommit = pkgs.writeShellScriptBin "ccommit" ''
    set -euo pipefail

    if ! command -v claude &> /dev/null; then
      echo "Error: 'claude' CLI not found in PATH"
      echo "Install via: https://docs.anthropic.com/en/docs/claude-code"
      exit 1
    fi

    tmpfile=$(mktemp /tmp/ccommit.XXXXXX.txt)
    trap "rm -f $tmpfile" EXIT

    ${pkgs.gum}/bin/gum spin --spinner dot --title "Generating commit message..." -- \
      bash -c 'claude -p "/commit $1" --system-prompt "$2" > "$3"' _ "$*" "${rawOutput}" "$tmpfile"
    git commit -e -m "$(cat "$tmpfile")"
  '';

  create-pr-from-file = pkgs.writeShellScriptBin "create-pr-from-file" ''
    set -euo pipefail
    tmpfile="$1"
    bodyfile=$(mktemp /tmp/cpr-body.XXXXXX.txt)
    trap "rm -f $bodyfile" EXIT

    ''${EDITOR:-vim} "$tmpfile"
    if [ -s "$tmpfile" ]; then
      title=$(head -n 1 "$tmpfile")
      tail -n +3 "$tmpfile" > "$bodyfile"
      env -u GITHUB_TOKEN ${pkgs.gh}/bin/gh pr create --title "$title" --body-file "$bodyfile"
    else
      echo "PR creation aborted (empty message)"
    fi
  '';

  cpr-full = pkgs.writeShellScriptBin "cpr-full" ''
    set -euo pipefail

    if ! command -v claude &> /dev/null; then
      echo "Error: 'claude' CLI not found in PATH"
      echo "Install via: https://docs.anthropic.com/en/docs/claude-code"
      exit 1
    fi

    tmpfile=$(mktemp /tmp/cpr.XXXXXX.md)
    trap "rm -f $tmpfile" EXIT

    ${pkgs.gum}/bin/gum spin --spinner dot --title "Generating PR description..." -- \
      bash -c 'claude -p "/pr $1" --system-prompt "$2" > "$3"' _ "$*" "${rawOutput}" "$tmpfile"
    ${create-pr-from-file}/bin/create-pr-from-file "$tmpfile"
  '';

  cpr-simple = pkgs.writeShellScriptBin "cpr-simple" ''
    set -euo pipefail

    if ! command -v claude &> /dev/null; then
      echo "Error: 'claude' CLI not found in PATH"
      echo "Install via: https://docs.anthropic.com/en/docs/claude-code"
      exit 1
    fi

    tmpfile=$(mktemp /tmp/cpr.XXXXXX.md)
    trap "rm -f $tmpfile" EXIT

    ${pkgs.gum}/bin/gum spin --spinner dot --title "Generating simple PR description..." -- \
      bash -c 'claude -p "/simple-pr $1" --system-prompt "$2" > "$3"' _ "$*" "${rawOutput}" "$tmpfile"
    ${create-pr-from-file}/bin/create-pr-from-file "$tmpfile"
  '';

  cpr = pkgs.writeShellScriptBin "cpr" ''
    set -euo pipefail
    choice=$(${pkgs.gum}/bin/gum choose "simple-pr" "full-pr")
    case "$choice" in
      full-pr)
        ${cpr-full}/bin/cpr-full "$@"
        ;;
      simple-pr)
        ${cpr-simple}/bin/cpr-simple "$@"
        ;;
    esac
  '';
in
{
  options.claude-git = {
    enable = lib.mkEnableOption "Claude Git helpers";
  };

  config = lib.mkIf cfg.enable {
    packages = [
      pkgs.gh
      pkgs.gum
      ccommit
      cpr
      cpr-full
      cpr-simple
    ];

    # Expose justfile template for inclusion
    # Import in your justfile with: import? "../.devenv/state/nix-shared/just/claude-git.just"
    env.CLAUDE_GIT_JUSTFILE = "${../..}/just/claude-git.just";

    enterShell = ''
      # Ensure skills are available (copy to project if not present)
      _claude_skills_src="${../..}/.claude/skills"
      if [ -d "$_claude_skills_src" ] && [ -d "$DEVENV_ROOT/.claude" ]; then
        for skill in commit pr simple-pr; do
          if [ ! -f "$DEVENV_ROOT/.claude/skills/$skill/SKILL.md" ] && [ -f "$_claude_skills_src/$skill/SKILL.md" ]; then
            mkdir -p "$DEVENV_ROOT/.claude/skills/$skill"
            cp "$_claude_skills_src/$skill/SKILL.md" "$DEVENV_ROOT/.claude/skills/$skill/"
          fi
        done
      fi

      # Alias for ccommit
      alias ccm=ccommit
    '';
  };
}
