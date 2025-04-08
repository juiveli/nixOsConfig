# Nix-podman-nicehash-quadlet
{
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };
  outputs = { nixpkgs, ... }@attrs: {
    homeManagerModules.quadlet = { config, lib, pkgs, ... }:
      let cfg = config.services.nix-podman-nicehash-nvidia-quadlet;
      in {

        options.services.nix-podman-nicehash-nvidia-quadlet = {
          enable = lib.mkEnableOption "nix-podman-nicehash-nvidia-quadlet";

          workerName = lib.mkOption {
            type = lib.types.str;
            default = "DEFAULT NAME";
          };
        };

        config = lib.mkIf cfg.enable {
          systemd.user.startServices = "sd-switch";

          virtualisation.quadlet.containers = {
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
          };
        };
      };
  };
}
