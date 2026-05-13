# Internal options for nix-shared devenv modules
{ lib, ... }:

{
  options.nix-shared._internal = {
    prefix = lib.mkOption {
      type = lib.types.str;
      default = "nix-shared";
      internal = true;
      readOnly = true;
      description = "Prefix for commands, paths, and identifiers";
    };
  };
}
