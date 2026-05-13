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
#     nix-shared.claude-git.enable = true;
#   }
#
# Provides (where prefix = config.nix-shared._internal.prefix):
#   - <prefix>-commit: Claude-assisted git commit (generates conventional commit message)
#   - <prefix>-pr: Claude-assisted PR creation (choose between full or simple)
#   - <prefix>-pr-full: Full PR generation
#   - <prefix>-pr-simple: Simple PR generation
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
  cfg = config.nix-shared.claude-git;
  prefix = config.nix-shared._internal.prefix;

  rawOutput = "You are a raw text generator. Output ONLY the content specified by the skill template. Do not add any text before or after. No introductions, no summaries, no questions, no commentary.";

  commitScript = pkgs.writeShellScriptBin "${prefix}-commit" ''
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

  createPrFromFileScript = pkgs.writeShellScriptBin "${prefix}-create-pr-from-file" ''
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

  prFullScript = pkgs.writeShellScriptBin "${prefix}-pr-full" ''
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
    ${createPrFromFileScript}/bin/${prefix}-create-pr-from-file "$tmpfile"
  '';

  prSimpleScript = pkgs.writeShellScriptBin "${prefix}-pr-simple" ''
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
    ${createPrFromFileScript}/bin/${prefix}-create-pr-from-file "$tmpfile"
  '';

  prScript = pkgs.writeShellScriptBin "${prefix}-pr" ''
    set -euo pipefail
    choice=$(${pkgs.gum}/bin/gum choose "simple-pr" "full-pr")
    case "$choice" in
      full-pr)
        ${prFullScript}/bin/${prefix}-pr-full "$@"
        ;;
      simple-pr)
        ${prSimpleScript}/bin/${prefix}-pr-simple "$@"
        ;;
    esac
  '';
  # Paths
  stateDir = "$DEVENV_STATE/claude-git";
  justfileDest = "${stateDir}/claude-git.just";
  skillsSrc = "${../..}/templates/skills";

  # Generated justfile content
  justfileContent = ''
    # Claude Git helpers
    # Import this in your project's justfile with:
    #   import? ".devenv/state/claude-git/claude-git.just"

    # Claude-assisted git commit
    [group('Git')]
    commit *ARGS:
        ${prefix}-commit {{ARGS}}

    # Claude-assisted PR creation (interactive choice: simple or full)
    [group('Git')]
    pr *ARGS:
        ${prefix}-pr {{ARGS}}

    # Simple PR generation
    [group('Git')]
    simple-pr *ARGS:
        ${prefix}-pr-simple {{ARGS}}

    # Full PR generation
    [group('Git')]
    full-pr *ARGS:
        ${prefix}-pr-full {{ARGS}}
  '';
  justfile = pkgs.writeText "claude-git.just" justfileContent;
in
{
  options.nix-shared.claude-git = {
    enable = lib.mkEnableOption "Claude Git helpers";
  };

  config = lib.mkIf cfg.enable {
    packages = [
      pkgs.gh
      pkgs.gum
      commitScript
      prScript
      prFullScript
      prSimpleScript
    ];

    scripts."${prefix}-update-skills".exec = ''
      SKILLS_SRC="${skillsSrc}" \
      SKILLS_DEST="$DEVENV_ROOT/.claude/skills/${prefix}" \
      ${pkgs.python3}/bin/python3 ${../..}/scripts/update_skills.py
    '';

    enterShell = ''
      # Copy justfile to devenv state
      # Import in your justfile with: import? ".devenv/state/claude-git/claude-git.just"
      mkdir -p "${stateDir}"
      cp -f "${justfile}" "${justfileDest}"

      # Copy skills to project (if project has .claude dir)
      _skills_src="${skillsSrc}"
      _skills_dest="$DEVENV_ROOT/.claude/skills/${prefix}"

      if [ -d "$_skills_src" ] && [ -d "$DEVENV_ROOT/.claude" ]; then
        for skill_file in "$_skills_src"/*/SKILL.md; do
          [ -f "$skill_file" ] || continue
          skill=$(basename "$(dirname "$skill_file")")
          mkdir -p "$_skills_dest/$skill"
          cp -n "$skill_file" "$_skills_dest/$skill/"
        done
      fi

      # Alias for ${prefix}-commit
      alias ccm=${prefix}-commit
    '';
  };
}
