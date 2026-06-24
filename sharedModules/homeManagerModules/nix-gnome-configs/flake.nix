{
  description = "Manage flatpak apps declaratively.";

  inputs = {

    nix-dev-toolkit.url = "github:juiveli/nix-dev-toolkit";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  };

  outputs =
    {
      self,
      nix-dev-toolkit,
      nixpkgs,
    }:
    {

      formatter = nix-dev-toolkit.formatter;
      checks = nix-dev-toolkit.checks;
      devShells = nix-dev-toolkit.devShells;

      homeManagerModules = {
        nix-gnome-home-configs = import ./gnome.nix;
      };
    };
}
