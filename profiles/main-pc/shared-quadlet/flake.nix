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
    nix-podman-testServer-quadlet = {
      url = "github:juiveli/nix-podman-testServer-quadlet";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-podman-caddy-quadlet = {
      url = "github:juiveli/nix-podman-caddy-quadlet";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      quadlet-nix,
      nix-podman-testServer-quadlet,
      nix-podman-caddy-quadlet,
      ...
    }@attrs:
    {
      nixosModules = {
        quadlet =
          { config, pkgs, ... }:

          {

            imports = [
              quadlet-nix.homeManagerModules.quadlet
              nix-podman-testServer-quadlet.nixosModules.quadlet
              nix-podman-caddy-quadlet.nixosModules.quadlet
            ];

          };
      };
    };
}
