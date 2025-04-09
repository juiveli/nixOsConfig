# Nix-podman-nicehash-quadlet
{
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };
  outputs = { nixpkgs, ... }@attrs: {
    homeManagerModules.quadlet = { config, lib, pkgs, ... }:
      let cfg = config.services.nix-podman-nicehash-quadlet;
      in {

        options.services.nix-podman-nicehash-quadlet = {

          enable =
            lib.mkEnableOption "Enable nix-podman-nicehash-quadlet service.";

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
                  podmanArgs = [ "--gpus" "all" "--interactive" "--tty" ];
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
  };
}
