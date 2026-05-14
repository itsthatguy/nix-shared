{ pkgs, lib, config, inputs, ... }:
let
  stubs = import ../lib/stubs.nix { inherit pkgs; };
in
{
  nix-shared.chrome-devtools.enable = true;

  packages = [ stubs.claude ];

  enterTest = ''
    echo "Testing chrome-devtools module loads and setup task is defined..."
    devenv tasks list | grep -q "nix-shared:setup"
    echo "✓ nix-shared:setup task exists"
  '';
}
