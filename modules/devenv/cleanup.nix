# nix-shared cleanup module
#
# Cleans up project-scoped Claude Code plugins and marketplaces
# that were installed by nix-shared modules but are no longer enabled.
#
# State is tracked in .devenv/state/nix-shared/{plugins,marketplaces}/

{
  config,
  lib,
  ...
}:

let
  stateDir = ".devenv/state/nix-shared";

  # Map marker filenames to their module enable state
  plugins = {
    "chrome-devtools-mcp@claude-plugins-official" = config.nix-shared.chrome-devtools.enable or false;
    "grepika@agentika-marketplace" = config.nix-shared.grepika.enable or false;
  };

  marketplaces = {
    "agentika-marketplace" = config.nix-shared.grepika.enable or false;
  };
in
{
  config.tasks."nix-shared:cleanup" = {
    exec = ''
      # Cleanup orphaned plugins (project scope only)
      if [ -d "${stateDir}/plugins" ]; then
        for marker in "${stateDir}/plugins"/*; do
          [ -f "$marker" ] || continue
          plugin="$(basename "$marker")"

          case "$plugin" in
            ${lib.concatStringsSep "\n            " (lib.mapAttrsToList (id: enabled:
              if enabled then ''${id}) ;;  # enabled, keep it''
              else ''${id})
                echo "Cleaning up plugin: $plugin (project scope)..."
                claude plugin uninstall "$plugin" --scope project 2>/dev/null || true
                rm -f "$marker"
                ;;''
            ) plugins)}
            *)
              # Unknown plugin marker - remove if plugin not installed
              if ! claude plugin list --scope project 2>/dev/null | grep -q "$plugin"; then
                rm -f "$marker"
              fi
              ;;
          esac
        done
      fi

      # Cleanup orphaned marketplaces (project scope only)
      if [ -d "${stateDir}/marketplaces" ]; then
        for marker in "${stateDir}/marketplaces"/*; do
          [ -f "$marker" ] || continue
          marketplace="$(basename "$marker")"

          case "$marketplace" in
            ${lib.concatStringsSep "\n            " (lib.mapAttrsToList (id: enabled:
              if enabled then ''${id}) ;;  # enabled, keep it''
              else ''${id})
                echo "Cleaning up marketplace: $marketplace..."
                claude plugin marketplace remove "$marketplace" 2>/dev/null || true
                rm -f "$marker"
                ;;''
            ) marketplaces)}
            *)
              rm -f "$marker"
              ;;
          esac
        done
      fi
    '';
    before = [ "devenv:enterShell" ];
  };
}
