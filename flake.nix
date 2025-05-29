{
  description = "Shared overlays for devenv.sh";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    overlays = rec {
      kubectx = import ./overlays/kubectx.nix;
      kubens = import ./overlays/kubens.nix;
      fzfWrapper = import ./overlays/fzf-wrapper.nix;
      default = [ kubectx kubens fzfWrapper ];
    };
  };
}
