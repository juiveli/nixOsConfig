{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-podman-quadlet-collection = {
      url = "./nix-podman-quadlet-collection";
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
      home-manager,
      main-pc,
      nixos-test,
      nixpkgs,
      nix-podman-quadlet-collection,
      packages,
    }@attrs:
    {
      nixosModules =
        let

          profile =
            {
              profileModules ? [ ],
              users ? { },
            }:
            {
              config,
              lib,
              pkgs,
              ...
            }:
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
                nix-podman-quadlet-collection.nixosModules.quadlet-collection
                packages.nixosModules.packages
              ] ++ profileModules;

              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];
              system.stateVersion = lib.mkDefault "24.11";

              custom.boot.loader.defaultSettings.enable = true;
              custom.defaultLocale.enable = lib.mkDefault true;
              custom.users.joonas.enable = lib.mkDefault true;

              services.displayManager.autoLogin = {
                enable = lib.mkDefault config.custom.users.joonas.enable;
                user = lib.mkDefault "joonas"; # Default to "joonas" but allows override.
              };

              custom.packages.gui.enable = lib.mkDefault true;
              custom.packages.guiless.enable = lib.mkDefault true;

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
                    ./home-manager-configs/gnome.nix
                    nix-podman-quadlet-collection.homeManagerModules.quadlet-collection
                  ];

                  home.username = lib.mkDefault username;
                  home.homeDirectory = lib.mkDefault "/home/${username}";
                  home.stateVersion = lib.mkDefault "24.11";

                  custom.gnome.dconfSettings.enable = lib.mkDefault true;

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
