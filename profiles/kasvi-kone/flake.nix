# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  inputs = {

    fundamentals = {
      url = "path:./../../sharedModules/fundamentals";
      inputs.nix-dev-toolkit.follows = "nix-dev-toolkit";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-dev-toolkit.url = "github:juiveli/nix-dev-toolkit";

    nix-flatpak.url = "github:gmodena/nix-flatpak"; # unstable branch. Use github:gmodena/nix-flatpak/?ref=<tag> to pin releases.

    nix-gnome-configs = {
      url = "path:./../../sharedModules/homeManagerModules/nix-gnome-configs";
      inputs.nix-dev-toolkit.follows = "nix-dev-toolkit";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    melonDS = {
      url = "github:melonDS-emu/melonDS";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      fundamentals,
      home-manager,
      melonDS,
      nix-dev-toolkit,
      nix-flatpak,
      nix-gnome-configs,
      nixpkgs,
      self,
      ...
    }:

    {

      formatter = nix-dev-toolkit.formatter;
      checks = nix-dev-toolkit.checks;
      devShells = nix-dev-toolkit.devShells;

      nixosConfigurations.kasvi-kone = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.kasvi-kone-specific
        ];
      };

      nixosModules = {
        kasvi-kone-specific =
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
              ./nixosModules/sara.nix
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
              }
              nix-flatpak.nixosModules.nix-flatpak

              fundamentals.nixosModules.nixos-fundamentals

            ];

            system.stateVersion = "26.05";

            swapDevices = [ { device = "/swap/swapfile"; } ];
            custom.desktop-environment.gnome.enable = true;

            services.displayManager.autoLogin = {
              enable = false;
            };

            home-manager.users.joonas =
              {
                pkgs,
                config,
                lib,
                ...
              }:
              {
                imports = [
                  nix-gnome-configs.homeManagerModules.nix-gnome-home-configs
                ];

                custom.gnome.dconfSettings.enable = true;

                home.stateVersion = "26.05";

              };

            networking.hostName = "kasvi-kone"; # Define your hostname.

            # Open ports in the firewall.
            networking.firewall.allowedTCPPorts = [
              3030 # Heroes3
            ];

            networking.firewall.allowedUDPPorts = [

            ];

            # Or disable the firewall altogether.
            networking.firewall.enable = true;

            system.autoUpgrade.enable = false;
            system.autoUpgrade.allowReboot = false;

            # Enable OpenGL
            hardware.graphics = {
              enable = true;
            };

            services.flatpak.enable = true;

            services.flatpak.packages = [
              {
                appId = "org.signal.Signal";
                origin = "flathub";
              }
              {
                appId = "com.heroicgameslauncher.hgl";
                origin = "flathub";
              }
              {
                appId = "eu.vcmi.VCMI";
                origin = "flathub";
              }

            ];

            environment.systemPackages = [

              pkgs.anytype
              pkgs.bolt-launcher # runescape launcher
              pkgs.mkvtoolnix

              pkgs.element-desktop
              # Minecraft custom launcher
              (pkgs.prismlauncher.override {
                # Add binary required by some mod
                additionalPrograms = [ pkgs.ffmpeg ];

                # Change Java runtimes available to Prism Launcher
                jdks = [
                  pkgs.graalvmPackages.graalvm-ce
                  pkgs.zulu8
                  pkgs.zulu17
                  pkgs.zulu
                ];
              })
              pkgs.transmission_4-qt6
              pkgs.vlc
              pkgs.inkscape-with-extensions
              pkgs.mumble
              pkgs.pinta
              pkgs.nvidia-container-toolkit
              pkgs.runelite
              pkgs.sops
              pkgs.sshfs
              pkgs.steam-run
              melonDS.packages.${pkgs.stdenv.hostPlatform.system}.default
            ];

            programs.steam = {
              enable = true;
              remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
              dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
              localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
            };

            services.hardware.openrgb = {
              enable = true;
              package = pkgs.openrgb-with-all-plugins;
              motherboard = "amd";
              server.port = 6742;
            };
          };
      };
    };
}
