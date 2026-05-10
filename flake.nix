{
  description = "Shared overlays and devenv modules";

  inputs.nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";

  outputs = { self, nixpkgs }: {
    overlays = rec {
      kubectx = import ./overlays/kubectx.nix;
      kubens = import ./overlays/kubens.nix;
      fzfWrapper = import ./overlays/fzf-wrapper.nix;
      default = nixpkgs.lib.composeManyExtensions [ kubectx kubens fzfWrapper ];
    };

    devenvModules = {
      chunkhound = ./modules/devenv/chunkhound.nix;
    };
  };
}
