{
  description = "A flake with multiple pc nixosConfigurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Utility providing formatter and checker
    nix-dev-toolkit.url = "github:juiveli/nix-dev-toolkit";

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
      nixpkgs,
      main-pc,
      nixos-router,
      nixos-test,
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
          nixos-test.nixosModules.nixos-test-specific
        ];
      };

      nixosConfigurations.main-pc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          main-pc.nixosModules.main-pc-specific
        ];
      };

      nixosConfigurations.nixos-router = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-router.nixosModules.nixos-router-specific
        ];
      };
    };
}
