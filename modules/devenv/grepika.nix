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
in
{
  options.nix-shared.grepika = {
    enable = lib.mkEnableOption "Grepika Claude Code plugin";
  };

  config = lib.mkIf cfg.enable {
    tasks = {
      "grepika:setup" = {
        exec = ''
          if ! claude plugin list 2>/dev/null | grep -q "grepika@agentika-marketplace"; then
            echo "Installing grepika Claude Code plugin..."
            repo="agentika-labs/agentika-plugin-marketplace"
            marketplace="agentika-marketplace"
            plugin="grepika@''${marketplace}"

            claude plugin marketplace add "$repo" --scope project 2>/dev/null || true
            claude plugin marketplace update "$marketplace" 2>/dev/null || true
            claude plugin install "$plugin" --scope project 2>/dev/null || true
          fi
        '';
        before = [ "devenv:enterShell" ];
      };
    };
  };
}
