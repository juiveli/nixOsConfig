{
  description = "A flake with multiple pc nixosConfigurations";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    common-configurations = {
      url = "./common-configurations";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-test.url = "./profiles/nixos-test";
    main-pc.url = "./profiles/main-pc";
  };

  outputs =
    {
      self,
      nixpkgs,
      common-configurations,
      nixos-test,
      main-pc,
      ...
    }@inputs:
    {
      nixosConfigurations.nixos-test = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          common-configurations.nixosModules.conffi
          nixos-test.nixosModules.conffi
        ];
      };

      nixosConfigurations.main-pc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          common-configurations.nixosModules.conffi
          main-pc.nixosModules.conffi
        ];
      };
    };
}
