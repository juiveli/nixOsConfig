{
  description = "A flake with multiple pc nixosConfigurations";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.nixos-test = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./profiles/nixos-test/configuration.nix ];
    };

    nixosConfigurations.main-pc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./profiles/main-pc/configuration.nix ];
    };
  };
}
