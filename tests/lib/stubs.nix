# Test stubs for external CLI tools
#
# Usage in test devenv.nix:
#   let
#     stubs = import ../lib/stubs.nix { inherit pkgs; };
#   in
#   {
#     packages = [ stubs.claude stubs.ollama stubs.pgrep ];
#   }

{ pkgs }:

{
  # Stub claude CLI - echoes args and exits successfully
  claude = pkgs.writeShellScriptBin "claude" ''
    echo "claude stub: $@"
    exit 0
  '';

  # Stub ollama CLI - handles serve/list/pull commands for CI testing
  ollama = pkgs.writeShellScriptBin "ollama" ''
    case "$1" in
      serve) sleep infinity ;;
      list) printf "NAME                       ID              SIZE      MODIFIED\nnomic-embed-text:latest    0a109f422b47    274 MB    1 hour ago\n" ;;
      pull) echo "Already up to date" ;;
      *) exit 0 ;;
    esac
  '';

  # Stub pgrep - reports ollama as running, passes through other queries
  pgrep = pkgs.writeShellScriptBin "pgrep" ''
    [[ "$*" == *"ollama"* ]] && echo "1" && exit 0
    /usr/bin/pgrep "$@"
  '';
}
