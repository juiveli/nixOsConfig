# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-router-functionalities.url = "github:juiveli/nix-router-functionalities";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      nix-router-functionalities,
      sops-nix,
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
              sops-nix.nixosModules.sops

            ];

            users.users.router = {
              # ...
              # required for auto start before user login
              linger = true;
              # required for rootless container with multiple users
              autoSubUidGidRange = true;
              uid = 1000;
            };

            home-manager.users.router =
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
                sops.age.keyFile = "/home/router/.config/sops/age/keys.txt";

              };

            sops.defaultSopsFile = ./secrets/root.yaml;
            sops.defaultSopsFormat = "yaml";
            sops.age.keyFile = "/home/router/.config/sops/age/keys.txt";

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
