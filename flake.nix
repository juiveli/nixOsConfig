{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    packages = {
      url = "/etc/nixos/all-configurations/packages";
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

    {

      formatter = nix-dev-toolkit.formatter;
      checks = nix-dev-toolkit.checks;
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

            custom.packages.gui.enable = lib.mkDefault true;
            custom.packages.guiless.enable = lib.mkDefault true;

          };

      };
    };
}
