{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quadlet-nix = {
      url = "github:SEIAROTg/quadlet-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    testServer = {
      url = "./testServer";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caddy = {
      url = "./caddy";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mmx = {
      url = "./mmx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, quadlet-nix, testServer, caddy, mmx
    , ... }@attrs: {

      nixosModules = {
        quadlet-collection = {
          imports = [ quadlet-nix.nixosModules.quadlet ];
        };
      };

      homeManagerModules = {
        quadlet-collection = { config, pkgs, ... }:

          {

            imports = [
              quadlet-nix.homeManagerModules.quadlet
              testServer.nixosModules.quadlet
              caddy.nixosModules.quadlet
              mmx.nixosModules.quadlet
            ];

          };
      };
    };
}
