{ pkgs, lib, config, inputs, ... }:
{
  nix-shared.chunkhound.enable = true;

  enterTest = ''
    echo "Testing chunkhound can load (verifies native deps on Linux)..."
    chunkhound --help > /dev/null
    echo "✓ chunkhound loads successfully"
  '';
}
