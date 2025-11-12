{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gnome-configs = {
      url = "github:juiveli/nix-gnome-configs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    packages = {
      url = "/etc/nixos/all-configurations/packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ###########
    # profiles

    main-pc = {
      url = "./profiles/main-pc";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-router = {
      url = "./profiles/nixos-router";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-test = {
      url = "./profiles/nixos-test";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      home-manager,
      main-pc,
      nixos-router,
      nixos-test,
      nixpkgs,
      nix-gnome-configs,
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
                --override-input all-configurations/main-pc/nix-router-functionalities /home/joonas/Documents/git-projects/nix-router-functionalities \
                --override-input all-configurations/nix-podman-quadlet-collection/caddy/hugo-blog /home/joonas/Documents/git-projects/hugo-blog \
                --impure
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
                home-manager.nixosModules.home-manager
                packages.nixosModules.packages
              ]
              ++ profileModules;

              environment.systemPackages = [ dev-rebuild ];

              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];

              # Intentionally commented out, so every system needs to set it themselfs
              # system.stateVersion = "25.05";

              custom.boot.loader.defaultSettings.enable = lib.mkDefault true;
              custom.defaultLocale.enable = lib.mkDefault true;

              custom.networking.defaultSettings.enable = lib.mkDefault true;

              custom.users.joonas.enable = lib.mkDefault true;

              custom.desktop-environment.gnome.enable = lib.mkDefault false;

              services.openssh.enable = lib.mkDefault true;

              services.displayManager.autoLogin = {
                enable = lib.mkDefault config.custom.users.joonas.enable;
                user = lib.mkDefault "joonas"; # Default to "joonas" but allows override.
              };

              custom.packages.gui.enable = lib.mkDefault true;
              custom.packages.guiless.enable = lib.mkDefault true;

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
                  ];

                  services.podman.enable = true;

                  home.username = lib.mkDefault username;
                  home.homeDirectory = lib.mkDefault config.users.users.${username}.home;

                  # Could not read value directly, as home-manager evaluation happens at the same time as non-homemanager, so if it is false, it would give error
                  custom.gnome.dconfSettings.enable = lib.mkDefault (
                    lib.attrByPath [ "custom" "desktop-environment" "gnome" "enable" ] false config
                  );

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

          nixos-router = profile {
            profileModules = [
              nixos-router.nixosModules.nixos-router-specific
            ];
            users = {
              joonas = {
                homeManagerModules = [

                ];
              };
            };
          };

          nixos-test = profile {
            profileModules = [
              nixos-test.nixosModules.nixos-test-specific
            ];
          };

        };
    };
}
