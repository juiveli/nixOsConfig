{
  description = "A flake with multiple pc nixosConfigurations";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    treefmt-nix.url = "github:numtide/treefmt-nix";

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
      systems,
      treefmt-nix,
      nixos-test,
      main-pc,
      ...
    }@inputs:

    let
      # Small tool to iterate over each systems
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});

      # Eval the treefmt modules from ./treefmt.nix
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
    in
    {
      # for `nix fmt`
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      # for `nix flake check`
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });

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
