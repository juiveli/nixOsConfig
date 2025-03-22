{ ... }:
{
  projectRootFile = "flake.nix";

  programs.nixfmt-rfc-style.enable = true;

  programs.mdsh.enable = true;
}
