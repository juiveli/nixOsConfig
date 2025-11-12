{
  description = "A flake with multiple pc nixosConfigurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Treefmt module: provides utilities for code formatting
    treefmt-nix.url = "github:juiveli/treefmt-configs";

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
      treefmt-nix,
      ...
    }@inputs:

    {
      # for `nix fmt`

      formatter = treefmt-nix.formatter;

      checks = treefmt-nix.checks;

      devShells = treefmt-nix.devShells;

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
