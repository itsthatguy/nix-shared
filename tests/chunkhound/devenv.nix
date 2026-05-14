{ pkgs, lib, config, inputs, ... }:
let
  stubs = import ../lib/stubs.nix { inherit pkgs; };
in
{
  nix-shared.chunkhound.enable = true;

  packages = [ stubs.ollama stubs.pgrep ];

  enterTest = ''
    echo "Testing chunkhound can load (verifies native deps on Linux)..."
    chunkhound --help > /dev/null
    echo "✓ chunkhound loads successfully"
  '';
}
