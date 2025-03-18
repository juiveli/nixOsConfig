{
  inputs = { nixpkgs.url = "nixpkgs/nixos-21.05"; };
  outputs = { self, nixpkgs }: {
    devShell.x86_64-linux =
      let pkgs = import nixpkgs { system = "x86_64-linux"; };
      in pkgs.mkShell {
        shellHook = ''
          echo "project root: ${self}"
        '';
      };
  };
}
