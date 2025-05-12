{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dns-ip-updater = {
      url = "github:juiveli/dns-ip-updater";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gnome-configs = {
      url = "github:juiveli/nix-gnome-configs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-podman-quadlet-collection = {
      url = "github:juiveli/nix-podman-quadlet-collection";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    packages = {
      url = "./packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ###########
    # profiles

    main-pc = {
      url = "./profiles/main-pc";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-test = {
      url = "./profiles/nixos-test";
    };

  };

  outputs =
    {
      self,
      dns-ip-updater,
      home-manager,
      main-pc,
      nixos-test,
      nixpkgs,
      nix-gnome-configs,
      nix-podman-quadlet-collection,
      packages,
    }@attrs:
    {
      nixosModules =
        let

          profile =
            {
              profileModules ? [ ],

              # `users` is a map where each key is a username homeManagerModules under specific user is added to their profile
              # Example:
              # users = {
              #   joonas = {
              #     homeManagerModules = [ ./custom-config.nix ];
              #   };
              # };
              users ? { },
            }:
            {
              config,
              lib,
              pkgs,
              ...
            }:

            let

              dev-rebuild = pkgs.writeShellScriptBin "dev-rebuild" ''
                nixos-rebuild switch --flake .# \
                --override-input all-configurations/dns-ip-updater /home/joonas/Documents/git-projects/dns-ip-updater \
                --override-input all-configurations/nix-gnome-configs /home/joonas/Documents/git-projects/nix-gnome-configs \
                --override-input all-configurations/nix-podman-quadlet-collection /home/joonas/Documents/git-projects/nix-podman-quadlet-collection \
                --override-input all-configurations/main-pc/nix-router-functionalities /home/joonas/Documents/git-projects/nix-router-functionalities
              '';

            in

            {

              ############################################

              # Non home-manager settings

              imports = [
                ./bootloader.nix
                ./desktop-environment.nix
                ./locale.nix
                ./networking.nix
                ./users/joonas.nix
                dns-ip-updater.nixosModules.quadlet
                home-manager.nixosModules.home-manager
                nix-podman-quadlet-collection.nixosModules.quadlet-collection
                packages.nixosModules.packages
              ] ++ profileModules;

              environment.systemPackages = [ dev-rebuild ]; 

              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];
              system.stateVersion = lib.mkDefault "24.11";

              custom.boot.loader.defaultSettings.enable = lib.mkDefault true;
              custom.defaultLocale.enable = lib.mkDefault true;

              custom.networking.defaultSettings.enable = lib.mkDefault true;

              custom.users.joonas.enable = lib.mkDefault true;
              custom.desktop-environment.gnome.enable = lib.mkDefault true;

              services.displayManager.autoLogin = {
                enable = lib.mkDefault config.custom.users.joonas.enable;
                user = lib.mkDefault "joonas"; # Default to "joonas" but allows override.
              };

              custom.packages.gui.enable = lib.mkDefault true;
              custom.packages.guiless.enable = lib.mkDefault true;

              services.dns-ip-updater.dy-fi.enable = lib.mkDefault false;

              # Folder creations
              services.nix-podman-caddy-quadlet.folder-creations.enable = lib.mkDefault false;
              services.nix-podman-chia-quadlet.folder-creations.enable = lib.mkDefault false;
              services.nix-podman-mmx-quadlet.folder-creations.enable = lib.mkDefault false;
              # testServer does not need folders to be created
              # nicehash does not need folder to be created

              ##################################################################

              # home-manager global settings

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              ##################################################################

              # home-manager user shared settings

              # Dynamically add user-specific Home Manager configurations
              home-manager.users = builtins.mapAttrs (
                username: userConfig:
                {
                  pkgs,
                  config,
                  lib,
                  ...
                }:
                {
                  imports = (userConfig.homeManagerModules or [ ]) ++ [
                    nix-gnome-configs.homeManagerModules.nix-gnome-home-configs
                    nix-podman-quadlet-collection.homeManagerModules.quadlet-collection
                  ];

                  home.username = lib.mkDefault username;
                  home.homeDirectory = lib.mkDefault config.users.users.${username}.home;
                  home.stateVersion = lib.mkDefault "24.11";

                  custom.gnome.dconfSettings.enable = lib.mkDefault config.custom.desktop-environment.gnome.enable;

                  # Podman quadlet enables
                  services.nix-podman-caddy-quadlet.enable = lib.mkDefault false;
                  services.nix-podman-chia-quadlet.enable = lib.mkDefault false;
                  services.nix-podman-mmx-quadlet.enable = lib.mkDefault false;
                  services.nix-podman-testServer-quadlet.enable = lib.mkDefault false;

                  services.nix-podman-nicehash-quadlet = {
                    workerName = lib.mkDefault config.network.hostName;
                    enable = lib.mkDefault false;
                    nvidia = lib.mkDefault false;
                    amd = lib.mkDefault false;
                  };

                }
              ) users; # Map users to their Home Manager configurations
            };
        in
        {

          main-pc = profile {
            profileModules = [
              ./profiles/main-pc/shared-module-config.nix
              main-pc.nixosModules.main-pc-specific
            ];
            users = {
              joonas = {
                homeManagerModules = [
                  ./profiles/main-pc/shared-module-home-manager-config.nix
                ];
              };
            };
          };

          nixos-test = profile {
            profileModules = [
              ./profiles/nixos-test/shared-module-config.nix
              nixos-test.nixosModules.nixos-test-specific
            ];
          };

        };
    };
}
