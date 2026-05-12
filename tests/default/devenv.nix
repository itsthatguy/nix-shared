{ pkgs, lib, config, inputs, ... }:
{
  # Test bundled module import - all modules available via single import
  nix-shared.claude-git.enable = true;
  nix-shared.grepika.enable = true;
  nix-shared.chunkhound.enable = true;
}
