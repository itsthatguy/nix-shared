{ pkgs, lib, config, inputs, ... }:
let
  stubs = import ../lib/stubs.nix { inherit pkgs; };
in
{
  nix-shared.grepika.enable = true;

  packages = [ stubs.claude ];

  enterTest = ''
    echo "Testing grepika module loads and task is defined..."
    devenv tasks list | grep -q "grepika:setup"
    echo "✓ grepika:setup task exists"
  '';
}
