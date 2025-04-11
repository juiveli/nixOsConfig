{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
    }@attrs:
    {
      nixosModules = {
        user-management =
          {
            config,
            lib,
            pkgs,
            ...
          }:
          {

            imports = [
              home-manager.nixosModules.home-manager
            ];

            users.users.joonas = {
              isNormalUser = true;
              description = "joonas";
              extraGroups = [
                "networkmanager"
                "wheel"
              ];
              packages = [ ];
            };

            services.displayManager.autoLogin.enable = true;
            services.displayManager.autoLogin.user = "joonas";

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.joonas = import ./home-manager-users/joonas/home.nix;

          };
      };
    };
}
