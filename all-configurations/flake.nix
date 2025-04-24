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
      inputs.nixpkgs.follows = "nixpkgs";
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
              # Combine shared imports with specific profile modules
              imports = [
                self.nixosModules.shared
                ./bootloader.nix
                ./desktop-environment.nix
                ./locale.nix
                ./networking.nix
                ./users/joonas.nix
                home-manager.nixosModules.home-manager
                nix-podman-quadlet-collection.nixosModules.quadlet-collection
                packages.nixosModules.packages
              ] ++ profileModules;

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

                  home.username = username;
                  home.homeDirectory = "/home/${username}";
                  home.stateVersion = lib.mkDefault "24.11";
                }
              ) users; # Map users to their Home Manager configurations
            };
        in
        {

          shared =
            {
              config,
              lib,
              pkgs,
              ...
            }:
            {

              ############################################
              # Non home-manager settings

              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];
              system.stateVersion = lib.mkDefault "24.11";

              services.displayManager.autoLogin.enable = true;
              services.displayManager.autoLogin.user = "joonas";

              ##################################################################

              # home-manager-settings

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

            };

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
