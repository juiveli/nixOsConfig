{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    user-management = {
      url = "./user-management";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    packages = {
      url = "./packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      packages,
      user-management,
    }@attrs:
    {
      nixosModules = {
        conffi =
          {
            config,
            lib,
            pkgs,
            ...
          }:
          {

            imports = [
              ./bootloader.nix
              ./desktop-environment.nix
              ./locale.nix
              ./networking.nix
              packages.nixosModules.packages
              user-management.nixosModules.user-management
            ];

            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
            ];
            system.stateVersion = lib.mkDefault "24.11";
          };
      };
    };
}
