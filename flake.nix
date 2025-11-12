{
  description = "A flake with multiple pc nixosConfigurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Utility providing formatter and checker
    nix-dev-toolkit.url = "github:juiveli/nix-dev-toolkit";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    all-configurations = {
      url = "./all-configurations";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      all-configurations,
      systems,
      nix-dev-toolkit,
      ...
    }@inputs:

    {
      formatter = nix-dev-toolkit.formatter;
      checks = nix-dev-toolkit.checks;
      devShells = nix-dev-toolkit.devShells;

      nixosConfigurations.nixos-test = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          all-configurations.nixosModules.nixos-test
        ];
      };

      nixosConfigurations.main-pc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          all-configurations.nixosModules.main-pc
        ];
      };

      nixosConfigurations.nixos-router = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          all-configurations.nixosModules.nixos-router
        ];
      };
    };
}
