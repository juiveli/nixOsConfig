# Nix-podman-nicehash-quadlet
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
          cfg = config.services.nix-podman-nicehash-quadlet;
        in
        {

          options.services.nix-podman-nicehash-quadlet = {

            enable = lib.mkEnableOption "Enable nix-podman-nicehash-quadlet service.";

            nvidia = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            amd = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };

            workerName = lib.mkOption {
              type = lib.types.str;
              default = "DEFAULT NAME";
            };
          };

          config = lib.mkIf cfg.enable {

            systemd.user.startServices = "sd-switch";
            virtualisation.quadlet.containers = lib.mkMerge [
              (lib.mkIf cfg.nvidia {
                nicehash-nvidia = {
                  autoStart = true;
                  serviceConfig = {
                    RestartSec = "10";
                    Restart = "always";
                  };
                  containerConfig = {
                    image = "dockerhubnh/nicehash:latest";
                    environments = {
                      MINING_ADDRESS = "39XsURuNHCf9umYDFydWcTMhJLgeKvmp6U";
                      MINING_WORKER_NAME = cfg.workerName;
                    };
                    podmanArgs = [
                      "--gpus"
                      "all"
                      "--interactive"
                      "--tty"
                    ];
                  };
                };
              })

              (lib.mkIf cfg.amd {

                virtualisation.quadlet.containers = {
                  nicehash-amd = {
                    autoStart = true;
                    serviceConfig = {
                      RestartSec = "10";
                      Restart = "always";
                    };
                    containerConfig = {
                      image = "dockerhubnh/nicehash:latest";
                      environments = {
                        MINING_ADDRESS = "39XsURuNHCf9umYDFydWcTMhJLgeKvmp6U";
                        MINING_WORKER_NAME = cfg.workerName;
                      };
                      podmanArgs = [
                        "--device=/dev/kfd"
                        "--device=/dev/dri"
                        "--interactive"
                        "--tty"
                      ];
                    };
                  };
                };
              })
            ];

          };
        };

      nixosModules.service =
        { config, lib, ... }:
        let
          cfg = config.services.nix-podman-nicehash-service;
        in
        {
          options.services.nix-podman-nicehash-service = {
            enable = lib.mkEnableOption "Nicehash Service User and HM setup";
            user = lib.mkOption {
              type = lib.types.str;
              default = "nicehash-user";
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
              description = "Dedicated nicehash Service User";
              home = "/var/lib/containers/Nicehash";
              createHome = true;
              linger = true; # Required for Podman to run without login
            };

            home-manager.users.${cfg.user} = {
              imports = [
                self.homeManagerModules.quadlet
                quadlet-nix.homeManagerModules.quadlet
              ];
              services.nix-podman-nicehash-quadlet.enable = true;
            };
          };
        };

    };
}
