# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  inputs = {

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    nix-router-functionalities.url = "github:juiveli/nix-router-functionalities";

    nix-template-config = {
      url = "github:juiveli/nix-template-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
      nix-router-functionalities,
      nix-template-config,
      sops-nix,
      ...
    }:

    {
      nixosModules = {
        nixos-router-specific =
          {
            pkgs,
            config,
            lib,
            ...
          }:
          {
            imports = [
              # Include the results of the hardware scan.
              ./nixosModules/hardware-configuration.nix
              nix-router-functionalities.nixosModules.dhcp
              nix-template-config.nixosModules.nixos-fundamentals
              sops-nix.nixosModules.sops

              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;

                # Optionally, use home-manager.extraSpecialArgs to pass
                # arguments to home.nix
              }

            ];

            system.stateVersion = "25.05";

            # Disabling tpm, so in start it does not use time to try to find it
            systemd.tpm2.enable = false;

            users.users.joonas = {
              # ...
              # required for auto start before user login
              linger = true;
              # required for rootless container with multiple users
              autoSubUidGidRange = true;
              uid = 1000;
            };

            networking.interfaces.enp6s0.useDHCP = false;
            networking.interfaces.enp6s0.ipv4.addresses = [
              {
                address = "192.168.1.2";
                prefixLength = 24;
              }
            ];

            networking.nameservers = [
              "9.9.9.9"
              "149.112.112.112"
            ];

            home-manager.users.joonas =
              {
                pkgs,
                config,
                lib,
                ...
              }:
              {
                imports = [
                  sops-nix.homeManagerModules.sops
                ];

                sops.defaultSopsFile = ./secrets/rootless.yaml;
                sops.defaultSopsFormat = "yaml";
                sops.age.keyFile = "/home/joonas/.config/sops/age/keys.txt";

                home.stateVersion = "25.05";

              };

            sops.defaultSopsFile = ./secrets/root.yaml;
            sops.defaultSopsFormat = "yaml";
            sops.age.keyFile = "/home/joonas/.config/sops/age/keys.txt";

            boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

            networking.hostName = "nixos-router"; # Define your hostname.

            # Open ports in the firewall.
            networking.firewall.allowedTCPPorts = [
              80
              443
            ];
            networking.firewall.allowedUDPPorts = [
              80
              443

            ];

            # Or disable the firewall altogether.
            networking.firewall.enable = true;

            system.autoUpgrade.enable = true;
            system.autoUpgrade.allowReboot = false;

            services.avahi.publish.enable = true;

            environment.systemPackages = [
              pkgs.sops

            ];
          };
      };
    };
}
