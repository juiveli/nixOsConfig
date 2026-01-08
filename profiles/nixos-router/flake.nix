# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  inputs = {

    fundamentals = {
      url = "github:juiveli/nixOsConfig?dir=sharedModules/fundamentals";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    nix-router-functionalities.url = "github:juiveli/nix-router-functionalities";

  };

  outputs =
    {
      nixpkgs,
      nix-router-functionalities,
      fundamentals,
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
              fundamentals.nixosModules.nixos-fundamentals

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

          };
      };
    };
}
