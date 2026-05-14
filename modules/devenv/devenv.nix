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
#     nix-shared.chrome-devtools.enable = true;
#     nix-shared.claude-git.enable = true;
#     nix-shared.chunkhound.enable = true;
#     nix-shared.grepika.enable = true;
#   }

{
  imports = [
    ./setup.nix
    ./chrome-devtools.nix
    ./chunkhound.nix
    ./claude-git.nix
    ./cleanup.nix
    ./grepika.nix
  ];
}
