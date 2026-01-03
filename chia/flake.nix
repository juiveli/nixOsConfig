# Nix-podman-chia-quadlet
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
  outputs =
    {
      self,
      home-manager,
      nixpkgs,
      quadlet-nix,
      sops-nix,
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
          cfg = config.services.nix-podman-chia-quadlet;
        in
        {

          options.services.nix-podman-chia-quadlet = {
            enable = lib.mkEnableOption "nix-podman-chia-quadlet";
          };

          imports = [
            quadlet-nix.homeManagerModules.quadlet
            sops-nix.homeManagerModules.sops
          ];

          config = lib.mkIf cfg.enable {

            sops.secrets = {
              chia-mnemonic = {
                sopsFile = ./mnemonic.yaml;
                format = "yaml";
              };
            };

            systemd.user.startServices = "sd-switch";

            virtualisation.quadlet.containers = {
              chia = {
                autoStart = true;
                serviceConfig = {
                  RestartSec = "10";
                  Restart = "always";
                };

                unitConfig = {
                  After = "sops-nix.service";
                  Requires = "sops-nix.service";
                };

                containerConfig = {
                  image = "ghcr.io/chia-network/chia:latest";
                  publishPorts = [ "8444:8444" ];

                  volumes = [
                    "${config.sops.secrets.chia-mnemonic.path}:/mnemonic.txt"
                    "/var/lib/containers/chia/chiaPlots:/plots"
                    "/var/lib/containers/chia/.chia:/root/.chia"
                  ];
                  environments = {
                    keys = "/mnemonic.txt";
                    recursive_plot_scan = "true";
                  };
                };
              };
            };
          };
        };

      nixosModules.folders =
        { config, lib, ... }:
        let
          cfg = config.services.nix-podman-chia-infra;
        in
        {
          options.services.nix-podman-chia-infra = {
            enable = lib.mkEnableOption "Chia directory structure";
            username = lib.mkOption { type = lib.types.str; };
            usergroup = lib.mkOption {
              type = lib.types.str;
              default = cfg.username;
            };
          };

          config = lib.mkIf cfg.enable {
            systemd.tmpfiles.settings."chia-folders" = {
              "/var/lib/containers/chia".d = {
                user = cfg.username;
                group = cfg.usergroup;
                mode = "0755";
              };
              "/var/lib/containers/chia/chiaPlots".d = {
                user = cfg.username;
                group = cfg.usergroup;
                mode = "0755";
              };
              "/var/lib/containers/chia/.chia".d = {
                user = cfg.username;
                group = cfg.usergroup;
                mode = "0755";
              };
            };
          };
        };

      nixosModules.service =
        { config, lib, ... }:
        let
          cfg = config.services.nix-podman-chia-service;
        in
        {
          options.services.nix-podman-chia-service = {
            enable = lib.mkEnableOption "Chia Service User and HM setup";
            user = lib.mkOption {
              type = lib.types.str;
              default = "chia-user";
            };

            homeStateVersion = lib.mkOption {
              type = lib.types.str;
              description = "The stateVersion for the Home Manager user.";
            };

          };

          imports = [
            home-manager.nixosModules.home-manager
            quadlet-nix.nixosModules.quadlet
            self.nixosModules.folders
          ];

          config = lib.mkIf cfg.enable {

            services.nix-podman-chia-infra = {
              enable = true;
              username = cfg.user;
            };

            users.groups.${cfg.user} = { };
            users.users.${cfg.user} = {
              isNormalUser = true;
              group = cfg.user;
              description = "Dedicated Chia Service User";
              home = "/var/lib/containers/chia";
              createHome = true;
              linger = true; # Required for Podman to run without login
            };

            home-manager.users.${cfg.user} = {
              imports = [ self.homeManagerModules.quadlet ];

              home.stateVersion = cfg.homeStateVersion;
              services.nix-podman-chia-quadlet.enable = true;
            };
          };
        };

    };
}
