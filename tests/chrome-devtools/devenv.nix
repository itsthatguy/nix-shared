{ pkgs, lib, config, inputs, ... }:
let
  stubs = import ../lib/stubs.nix { inherit pkgs; };
in
{
  nix-shared.chrome-devtools.enable = true;

  packages = [ stubs.claude ];

  enterTest = ''
    echo "Testing chrome-devtools module loads and task is defined..."
    devenv tasks list | grep -q "chrome-devtools:setup"
    echo "✓ chrome-devtools:setup task exists"
  '';
}
