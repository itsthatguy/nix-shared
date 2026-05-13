# nix-shared devenv modules
#
# Usage in devenv.yaml:
#   inputs:
#     nix-shared:
#       url: github:itsthatguy/nix-shared
#
#   imports:
#     - nix-shared/modules/devenv
#
# Usage in devenv.nix:
#   {
#     nix-shared.claude-git.enable = true;
#     nix-shared.grepika.enable = true;
#     nix-shared.chunkhound.enable = true;
#   }

{
  imports = [
    ./lib.nix
    ./chunkhound.nix
    ./claude-git.nix
    ./grepika.nix
  ];
}
