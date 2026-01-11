# Nix-podman-any-sync-bundle-quadlet
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
      nixpkgs,
      home-manager,
      quadlet-nix,
      sops-nix,
      ...
    }:
    {
      homeManagerModules.quadlet =
        {
          config,
          lib,
          pkgs,
          ...
        }:

        let
          cfg = config.services.nix-podman-any-sync-bundle-quadlet;

        in
        {

          options.services.nix-podman-any-sync-bundle-quadlet = {
            enable = lib.mkEnableOption "nix-podman-any-sync-bundle-quadlet";

            bundle-configPath = lib.mkOption {
              type = lib.types.path;
              description = "Path to the decrypted bundle-config.yml";
            };

          };

          imports = [
            quadlet-nix.homeManagerModules.quadlet
          ];

          config = lib.mkIf cfg.enable {

            systemd.user.startServices = "sd-switch";

            # Quadlet container configuration
            virtualisation.quadlet.containers = {
              any-sync-bundle-aio = {
                autoStart = true;
                serviceConfig = {
                  RestartSec = "10";
                  Restart = "always";
                };

                unitConfig = {
                  After = [ "network-online.target" ];
                };

                containerConfig = {
                  image = "ghcr.io/grishy/any-sync-bundle:1.2.1-2025-12-10"; # https://github.com/grishy/any-sync-bundle

                  publishPorts = [
                    "33010:33010"
                    "33020:33020/udp"
                  ];
                  volumes = [
                    "/var/lib/containers/any-sync-bundle/data:/data"
                  ];

                  environments = {
                    ANY_SYNC_BUNDLE_INIT_EXTERNAL_ADDRS = "192.168.1.117, juiveli.fi";
                    ANY_SYNC_BUNDLE_CONFIG = "${cfg.bundle-configPath}";
                  };

                };
              };
            };
          };
        };

      nixosModules.folders =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let

          cfg = config.services.nix-podman-any-sync-bundle-infra;
        in
        {

          options.services.nix-podman-any-sync-bundle-infra = {
            enable = lib.mkEnableOption "create necessary folders";
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

              "any-sync-bundle_topfolder" = {

                "/var/lib/containers/any-sync-bundle" = {
                  d = {
                    group = cfg.usergroup;
                    mode = "0755";
                    user = cfg.username;
                  };
                };

              };

              "any-sync-bundle_folders" = {

                "/var/lib/containers/any-sync-bundle/data" = {
                  d = {
                    group = cfg.usergroup;
                    mode = "0755";
                    user = cfg.username;
                  };
                };

              };
            };
          };
        };

      nixosModules.service =
        { config, lib, ... }:
        let
          cfg = config.services.nix-podman-any-sync-bundle-service;
        in
        {
          options.services.nix-podman-any-sync-bundle-service = {
            enable = lib.mkEnableOption "Any-sync-bundle Service User and HM setup";
            user = lib.mkOption {
              type = lib.types.str;
              default = "any-sync-bundle-user";
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

            services.nix-podman-any-sync-bundle-infra = {
              enable = true;
              username = cfg.user;
            };

            users.groups.${cfg.user} = { };
            users.users.${cfg.user} = {
              isNormalUser = true;
              group = cfg.user;
              description = "Dedicated any-sync-bundle Service User";
              home = "/var/lib/containers/any-sync-bundle/home";
              createHome = true;
              linger = true; # Required for Podman to run without login
            };

            virtualisation.quadlet.enable = true;

            sops.secrets = {
              any-sync-bundle-config = {
                sopsFile = ./any-sync-bundle-config.yaml;
                format = "yaml";
                key = ""; # Gets the whole file
                owner = cfg.user;
                group = cfg.user;
                mode = "0400";
              };
            };

            home-manager.users.${cfg.user} = {
              imports = [ self.homeManagerModules.quadlet ];

              home.stateVersion = cfg.homeStateVersion;

              services.nix-podman-any-sync-bundle-quadlet = {
                enable = true;
                bundle-configPath = config.sops.secrets.any-sync-bundle-config.path;

              };

            };
          };
        };
    };
}
