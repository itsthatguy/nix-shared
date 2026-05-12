# Grepika devenv module
#
# Usage in devenv.yaml:
#   inputs:
#     nix-shared:
#       url: github:itsthatguy/nix-shared
#
#   imports:
#     - nix-shared/modules/devenv/grepika.nix
#
# Usage in devenv.nix:
#   {
#     nix-shared.grepika.enable = true;
#
#     # Optional overrides:
#     # nix-shared.grepika.root = ".";  # defaults to $DEVENV_ROOT
#   }
#
# Provides:
#   - grepika command (wraps grepika with --db pointing to devenv state)

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nix-shared.grepika;

  grepikaDb = "$DEVENV_STATE/grepika.db";
in
{
  options.nix-shared.grepika = {
    enable = lib.mkEnableOption "Grepika code search";

    root = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Root directory to search (defaults to $DEVENV_ROOT if empty)";
    };
  };

  config = lib.mkIf cfg.enable {
    packages = [
      pkgs.nodejs
    ];

    scripts.grepika.exec = ''
      root_arg=""
      if [ -n "${cfg.root}" ]; then
        root_arg="--root ${cfg.root}"
      else
        root_arg="--root $DEVENV_ROOT"
      fi

      npx -y @agentika/grepika --db "${grepikaDb}" $root_arg "$@"
    '';

  };
}
