{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  stubs = import ../lib/stubs.nix { inherit pkgs; };
in
{
  # Test bundled module import - all modules available via single import
  nix-shared.claude-git.enable = true;
  nix-shared.chunkhound.enable = true;
  nix-shared.grepika.enable = true;

  packages = [ stubs.claude ];
}
