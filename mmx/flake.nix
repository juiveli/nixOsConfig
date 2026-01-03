# Nix-mmx-quadlet
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
          cfg = config.services.nix-podman-mmx-quadlet;

          # Define the script in the Nix store using pkgs.writeScript
          createWalletScript = pkgs.writeScript "create-wallet-and-start-mmx" ''
            #!/bin/bash


            source ./activate.sh

            WALLET_FILE="/data/wallet.dat"

            MNEMONIC=$(cat /mnemonic.yaml)

            # Check if the wallet exists; create it if not
            if [ ! -f $WALLET_FILE ]; then
                echo "Wallet not found. Creating wallet..."
                mmx wallet create --mnemonic $MNEMONIC

            else
                echo "Wallet already exists."
            fi

            # Start MMX node
            echo "Starting MMX node..."
            ./run_node.sh
          '';

        in
        {

          options.services.nix-podman-mmx-quadlet = {
            enable = lib.mkEnableOption "nix-podman-mmx-quadlet";
          };

          imports = [
            quadlet-nix.homeManagerModules.quadlet
            sops-nix.homeManagerModules.sops
          ];

          config = lib.mkIf cfg.enable {

            sops.secrets = {
              mmx-mnemonic = {
                sopsFile = ./mnemonic.yaml;
                format = "yaml";
              };
            };

            systemd.user.startServices = "sd-switch";

            # Quadlet container configuration
            virtualisation.quadlet.containers = {
              mmx = {
                autoStart = true;

                # Service-specific configurations
                serviceConfig = {
                  RestartSec = "10";
                  Restart = "always";
                };

                unitConfig = {
                  After = "sops-nix.service";
                  Requires = "sops-nix.service";
                };

                # Container-specific configurations
                containerConfig = {
                  image = "ghcr.io/madmax43v3r/mmx-node:edge"; # MMX container image
                  networks = [ "host" ]; # Use host networking
                  volumes = [
                    "/var/lib/containers/mmx/data/:/data" # Persistent data storage
                    "/var/lib/containers/mmx/mmxPlots/:/mmxPlots" # Plots directory
                    "${createWalletScript}:/usr/local/bin/create-wallet-and-start-mmx.sh" # Correctly mount the script file
                    "${config.sops.secrets.mmx-mnemonic.path}:/mnemonic.yaml"
                    "${./Harvester.json}:/data/config/local/Harvester.json"
                  ];
                  entrypoint = "/usr/local/bin/create-wallet-and-start-mmx.sh"; # Script itself is the entrypoint
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

          cfg = config.services.nix-podman-mmx-infra;
        in
        {

          options.services.nix-podman-mmx-infra = {
            enable = lib.mkEnableOption "mmx directory structure";
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
                    group = cfg.usergroup;
                    mode = "0755";
                    user = cfg.username;
                  };
                };
              };

              "mmx_folders" = {
                "/var/lib/containers/mmx/data" = {
                  d = {
                    group = cfg.usergroup;
                    mode = "0755";
                    user = cfg.username;
                  };
                };

                "/var/lib/containers/mmx/mmxPlots" = {
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
          cfg = config.services.nix-podman-mmx-service;
        in
        {
          options.services.nix-podman-mmx-service = {
            enable = lib.mkEnableOption "MMX Service User and HM setup";
            user = lib.mkOption {
              type = lib.types.str;
              default = "mmx-user";
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

            services.nix-podman-mmx-infra = {
              enable = true;
              username = cfg.user;
            };

            users.groups.${cfg.user} = { };
            users.users.${cfg.user} = {
              isNormalUser = true;
              group = cfg.user;
              description = "Dedicated MMX Service User";
              home = "/var/lib/containers/mmx";
              createHome = true;
              linger = true; # Required for Podman to run without login
            };

            home-manager.users.${cfg.user} = {
              imports = [ self.homeManagerModules.quadlet ];

              home.stateVersion = cfg.homeStateVersion;
              services.nix-podman-mmx-quadlet.enable = true;
            };
          };
        };
    };
}
