{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    packages = {
      url = "./packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-dev-toolkit.url = "github:juiveli/nix-dev-toolkit";

  };

  outputs =
    {
      self,
      nix-dev-toolkit,
      nixpkgs,
      packages,
    }@attrs:

    let

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      # Standard helper to generate attributes for each system

      eachSystem = nixpkgs.lib.genAttrs supportedSystems;

    in

    {

      formatter = nix-dev-toolkit.formatter;
      checks = eachSystem (

        system:

        let

          # 1. Grab the existing checks for this specific system from the toolkit
          baseChecks = nix-dev-toolkit.checks.${system};

          # 2. Define your project-specific logic tests
          logicTests = {

            test-fundamentals-with-default = nix-dev-toolkit.lib.mkLogicCheck {
              system = system;
              nixpkgs = nixpkgs;
              module = self.nixosModules.nixos-fundamentals;
              config = { };
            };

            test-fundamentals-with-gnome = nix-dev-toolkit.lib.mkLogicCheck {
              system = system;
              nixpkgs = nixpkgs;
              module = self.nixosModules.nixos-fundamentals;
              config = {
                config.custom.desktop-environment.gnome.enable = true;
              };
            };

          };

        in

        baseChecks // logicTests

      );

      devShells = nix-dev-toolkit.devShells;

      nixosModules = {
        nixos-fundamentals =
          {
            config,
            lib,
            pkgs,
            ...
          }:

          {

            ############################################

            imports = [
              ./bootloader.nix
              ./desktop-environment.nix
              ./locale.nix
              ./networking.nix
              ./users/joonas.nix
              packages.nixosModules.packages
            ];

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

            custom.packages.gui.enable = lib.mkDefault config.custom.desktop-environment.gnome.enable;
            custom.packages.guiless.enable = lib.mkDefault true;

          };

      };
    };
}
