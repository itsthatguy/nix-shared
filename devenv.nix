{
  pkgs,
  ...
}:

{
  packages = with pkgs; [
    git
    gum
    just
  ];

  nix-shared = {
    claude-git.enable = true;
    grepika.enable = true;
  };
}
