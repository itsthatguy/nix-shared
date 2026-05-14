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
#   }
#
# On shell entry, installs the grepika Claude Code plugin at project scope.
# The plugin config is written to .claude/settings.json (shareable via git).

{
  config,
  lib,
  ...
}:

let
  cfg = config.nix-shared.grepika;
  stateDir = ".devenv/state/nix-shared";
  marketplace = "agentika-marketplace";
  pluginId = "grepika@${marketplace}";
in
{
  options.nix-shared.grepika = {
    enable = lib.mkEnableOption "Grepika Claude Code plugin";
  };

  config = lib.mkIf cfg.enable {
    nix-shared.plugins.setupScripts = [
      ''
        echo "Ensuring grepika Claude Code plugin..."
        repo="agentika-labs/agentika-plugin-marketplace"

        claude plugin marketplace add "$repo" --scope project 2>/dev/null || true
        claude plugin marketplace update "${marketplace}" 2>/dev/null || true
        claude plugin install "${pluginId}" --scope project 2>/dev/null || true

        mkdir -p "${stateDir}/plugins" "${stateDir}/marketplaces"
        touch "${stateDir}/plugins/${pluginId}"
        touch "${stateDir}/marketplaces/${marketplace}"
      ''
    ];
  };
}
