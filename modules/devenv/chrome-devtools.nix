# Chrome DevTools devenv module
#
# Usage in devenv.yaml:
#   inputs:
#     nix-shared:
#       url: github:itsthatguy/nix-shared
#
#   imports:
#     - nix-shared/modules/devenv/chrome-devtools.nix
#
# Usage in devenv.nix:
#   {
#     nix-shared.chrome-devtools.enable = true;
#   }
#
# On shell entry, installs the chrome-devtools Claude Code plugin at project scope.
# The plugin config is written to .claude/settings.json (shareable via git).

{
  config,
  lib,
  ...
}:

let
  cfg = config.nix-shared.chrome-devtools;
  stateDir = ".devenv/state/nix-shared";
  pluginId = "chrome-devtools-mcp@claude-plugins-official";
in
{
  options.nix-shared.chrome-devtools = {
    enable = lib.mkEnableOption "Chrome DevTools Claude Code plugin";
  };

  config = lib.mkIf cfg.enable {
    nix-shared.plugins.setupScripts = [
      ''
        echo "Ensuring chrome-devtools Claude Code plugin..."
        claude plugin install ${pluginId} --scope project 2>/dev/null || true
        mkdir -p "${stateDir}/plugins"
        touch "${stateDir}/plugins/${pluginId}"
      ''
    ];
  };
}
