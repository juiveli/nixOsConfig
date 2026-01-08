{
  description = "A flake with multiple pc nixosConfigurations";

  inputs = {

    # Utility providing formatter and checker
    nix-dev-toolkit.url = "github:juiveli/nix-dev-toolkit";

    main-pc = {
      url = "./profiles/main-pc";
    };

    nixos-router = {
      url = "./profiles/nixos-router";
    };

    nixos-test = {
      url = "./profiles/nixos-test";
    };
  };

  outputs =
    {
      main-pc,
      nixos-router,
      nixos-test,
      nix-dev-toolkit,
      ...
    }:

    {
      formatter = nix-dev-toolkit.formatter;
      checks = nix-dev-toolkit.checks;
      devShells = nix-dev-toolkit.devShells;

      nixosConfigurations.nixos-test = nixos-test.inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-test.nixosModules.nixos-test-specific
        ];
      };

      nixosConfigurations.main-pc = main-pc.inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          main-pc.nixosModules.main-pc-specific
        ];
      };

      nixosConfigurations.nixos-router = nixos-router.inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-router.nixosModules.nixos-router-specific
        ];
      };
    };
}
