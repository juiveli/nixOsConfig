{
  description = "A flake with multiple pc nixosConfigurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    # Treefmt module: provides utilities for code formatting
    treefmt-nix.url = "github:numtide/treefmt-nix";

    pre-commit-hooks.url = "github:cachix/git-hooks.nix";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    common-configurations = {
      url = "./common-configurations";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nixos-test = {
      url = "./profiles/nixos-test";
    };

    main-pc = {
      url = "./profiles/main-pc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      # Small tool to iterate over each system
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});

      # Eval the treefmt modules from ./treefmt.nix
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);

    in
    {
      # for `nix fmt`
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      checks = eachSystem (
        pkgs:
        let
          # Cache the pre-commit-check evaluation
          preCommitCheck = inputs.pre-commit-hooks.lib.${pkgs.system}.run {
            src = ./.;
            hooks = {
              nixfmt-rfc-style.enable = true;
              mdformat.enable = true;
            };
          };
        in
        {
          formatting = treefmtEval.${pkgs.system}.config.build.check self;

          pre-commit-check = preCommitCheck;

          # Optimize enabledPackages by filtering for critical dependencies
          enabledPackages = builtins.filter (pkg: pkg.isCritical == true) preCommitCheck.enabledPackages;
        }
      );

      devShells = eachSystem (pkgs: {
        default = nixpkgs.legacyPackages.${pkgs.system}.mkShell {
          inherit (self.checks.${pkgs.system}.pre-commit-check) shellHook;
          buildInputs = self.checks.${pkgs.system}.pre-commit-check.enabledPackages;
        };
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
