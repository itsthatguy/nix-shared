# Test stubs for external CLI tools
#
# Usage in test devenv.nix:
#   let
#     stubs = import ../lib/stubs.nix { inherit pkgs; };
#   in
#   {
#     packages = [ stubs.claude ];
#   }

{ pkgs }:

{
  # Stub claude CLI - echoes args and exits successfully
  claude = pkgs.writeShellScriptBin "claude" ''
    echo "claude stub: $@"
    exit 0
  '';
}
