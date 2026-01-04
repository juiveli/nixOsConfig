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

            mnemonicPath = lib.mkOption {
              type = lib.types.path;
              description = "Path to the decrypted mnemonic file";
            };
          };

          imports = [
            quadlet-nix.homeManagerModules.quadlet
          ];

          config = lib.mkIf cfg.enable {

            systemd.user.startServices = "sd-switch";

            virtualisation.quadlet.containers = {
              chia = {
                autoStart = true;
                serviceConfig = {
                  RestartSec = "10";
                  Restart = "always";
                };

                unitConfig = {
                  After = [ "network-online.target" ];
                };

                containerConfig = {
                  image = "ghcr.io/chia-network/chia:latest";
                  publishPorts = [ "8444:8444" ];

                  volumes = [
                    "${toString cfg.mnemonicPath}:/mnemonic.txt"
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
            enable = lib.mkEnableOption "Create necessart folders for appflowy";
            username = lib.mkOption { type = lib.types.str; };
            usergroup = lib.mkOption {
              type = lib.types.str;
              default = cfg.username;
            };
          };

          config = lib.mkIf cfg.enable {

            systemd.tmpfiles.settings = {

              "containers_folder" = {
                "/var/lib/containers" = {

                  d = {
                  };
                };
              };

              "chia-folders" = {
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
        };

      nixosModules.service =
        { config, lib, ... }:
        let
          cfg = config.services.nix-podman-chia-service;
        in
        {
          options.services.nix-podman-chia-service = {
            enable = lib.mkEnableOption "Chia Service User, sops-nix, and HM setup with";
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
            sops-nix.nixosModules.sops
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

            sops.secrets = {
              chia-mnemonic = {
                sopsFile = ./mnemonic.yaml;
                format = "yaml";
                owner = cfg.user;
                group = cfg.user;
                mode = "0400";
              };
            };

            home-manager.users.${cfg.user} = {
              imports = [ self.homeManagerModules.quadlet ];

              home.stateVersion = cfg.homeStateVersion;
              services.nix-podman-chia-quadlet = {
                enable = true;
                mnemonicPath = config.sops.secrets.chia-mnemonic.path;
              };
            };
          };
        };

    };
}
