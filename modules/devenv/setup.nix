# Central setup task for nix-shared plugins
#
# Runs all plugin setup scripts sequentially to avoid race conditions
# when multiple plugins modify .claude/settings.json

{
  config,
  lib,
  ...
}:

let
  scripts = config.nix-shared.plugins.setupScripts;
in
{
  options.nix-shared.plugins.setupScripts = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "List of plugin setup scripts to run sequentially";
  };

  config = lib.mkIf (scripts != []) {
    tasks."nix-shared:setup" = {
      exec = lib.concatStringsSep "\n" scripts;
      before = [ "devenv:enterShell" ];
    };
  };
}
