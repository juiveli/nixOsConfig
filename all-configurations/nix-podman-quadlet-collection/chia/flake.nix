# Nix-podman-chia-quadlet
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs =
    { nixpkgs, ... }@attrs:
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

      nixosModules.quadlet =
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
            folder-creations.enable = lib.mkEnableOption "nix-podman-chia-quadlet.folder-creations";
            username = lib.mkOption {
              type = lib.types.str;
              default = "joonas";
            };
            usergroup = lib.mkOption {
              type = lib.types.str;
              default = "users";
            };
          };

          config = lib.mkIf cfg.folder-creations.enable {

            systemd.tmpfiles.settings = {
              "containers_folder" = {
                "/var/lib/containers" = {

                  d = {
                    group = cfg.usergroup;
                    mode = "0755";
                    user = cfg.username;
                  };
                };
              };

              "chia_folders" = {
                "/var/lib/containers/chia" = {
                  d = {
                    group = cfg.usergroup;
                    mode = "0755";
                    user = cfg.username;
                  };
                };

                "/var/lib/containers/chia/chiaPlots" = {
                  d = {
                    group = cfg.usergroup;
                    mode = "0755";
                    user = cfg.username;
                  };
                };

                "/var/lib/containers/chia/.chia" = {
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
    };
}
