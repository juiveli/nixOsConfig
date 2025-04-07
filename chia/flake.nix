# Nix-podman-chia-quadlet
{
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };
  outputs = { nixpkgs, ... }@attrs: {
    homeManagerModules.quadlet = { config, lib, pkgs, ... }:

      let cfg = config.services.nix-podman-chia-quadlet;
      in {

        options.services.nix-podman-chia-quadlet = {
          enable = lib.mkEnableOption "nix-podman-chia-quadlet";
        };

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
  };
}

