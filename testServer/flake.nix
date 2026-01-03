# Nix-podman-testServer-quadlet
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";

  };
  outputs =
    {
      self,
      home-manager,
      nixpkgs,
      quadlet-nix,
      ...
    }@attrs:
    {
      homeManagerModules.quadlet =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.services.nix-podman-testServer-quadlet;
        in
        {

          options.services.nix-podman-testServer-quadlet = {
            enable = lib.mkEnableOption "nix-podman-testServer-quadlet";
          };

          config = lib.mkIf cfg.enable {
            systemd.user.startServices = "sd-switch";

            virtualisation.quadlet.containers = {
              testServer = {
                autoStart = true;
                serviceConfig = {
                  RestartSec = "10";
                  Restart = "always";
                };
                containerConfig = {
                  image = "quay.io/libpod/banner:latest";
                  publishPorts = [ "8001:80" ];
                };
              };
            };
          };
        };

      nixosModules.service =
        { config, lib, ... }:
        let
          cfg = config.services.nix-podman-testServer-service;
        in
        {
          options.services.nix-podman-testServer-service = {
            enable = lib.mkEnableOption "testServer Service User and HM setup";
            user = lib.mkOption {
              type = lib.types.str;
              default = "testServer-user";
            };

            homeStateVersion = lib.mkOption {
              type = lib.types.str;
              description = "The stateVersion for the Home Manager user.";
            };
          };

          imports = [
            home-manager.nixosModules.home-manager
            quadlet-nix.nixosModules.quadlet
          ];

          config = lib.mkIf cfg.enable {

            users.groups.${cfg.user} = { };
            users.users.${cfg.user} = {
              isNormalUser = true;
              group = cfg.user;
              description = "Dedicated testServer Service User";
              home = "/var/lib/containers/testServer";
              createHome = true;
              linger = true; # Required for Podman to run without login
            };

            home-manager.users.${cfg.user} = {
              imports = [
                self.homeManagerModules.quadlet
                quadlet-nix.homeManagerModules.quadlet
              ];

              home.stateVersion = cfg.homeStateVersion;
              services.nix-podman-testServer-quadlet.enable = true;
            };
          };
        };

    };
}
