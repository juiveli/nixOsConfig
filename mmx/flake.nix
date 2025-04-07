# Nix-mmx-quadlet
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { nixpkgs, sops-nix, ... }: {
    nixosModules.quadlet = { config, lib, pkgs, ... }:

      let

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

      in {

        sops.secrets = {
          mnemonic = {
            sopsFile = ./mnemonic.yaml;
            format = "yaml";
          };
        };

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
                "${config.sops.secrets.mnemonic.path}:/mnemonic.yaml"
              ];
              entrypoint =
                "/usr/local/bin/create-wallet-and-start-mmx.sh"; # Script itself is the entrypoint
            };
          };
        };
      };
  };
}
