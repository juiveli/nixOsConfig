{
  inputs = {

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    nix-dev-toolkit = {
      url = "github:juiveli/nix-dev-toolkit";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    appflowy = {
      url = "./appflowy";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.quadlet-nix.follows = "quadlet-nix";
    };

    testServer = {
      url = "./testServer";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quadlet-nix.follows = "quadlet-nix";
    };

    caddy = {
      url = "./caddy";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.quadlet-nix.follows = "quadlet-nix";
    };

    mmx = {
      url = "./mmx";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.sops-nix.follows = "sops-nix";
      inputs.quadlet-nix.follows = "quadlet-nix";
    };

    chia = {
      url = "./chia";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.sops-nix.follows = "sops-nix";
      inputs.quadlet-nix.follows = "quadlet-nix";
    };

    nicehash = {
      url = "./nicehash";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.quadlet-nix.follows = "quadlet-nix";
    };

    sshServerJohannes = {
      url = "./sshServerJohannes";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quadlet-nix.follows = "quadlet-nix";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      appflowy,
      nix-dev-toolkit,
      testServer,
      caddy,
      nicehash,
      mmx,
      chia,
      sshServerJohannes,
      ...
    }@attrs:

    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      # Standard helper to generate attributes for each system
      eachSystem = nixpkgs.lib.genAttrs supportedSystems;

    in

    {

      formatter = nix-dev-toolkit.formatter;

      checks = eachSystem (
        system:

        let
          # 1. Grab the existing checks for this specific system from the toolkit
          baseChecks = nix-dev-toolkit.checks.${system};

          # 2. Define your project-specific logic tests
          logicTests = {

            test-empty-config = nix-dev-toolkit.lib.mkLogicCheck {
              system = system;
              nixpkgs = nixpkgs;
              module = self.nixosModules.quadlet-collection;
              config = {
              };
            };

            test-appflowy = nix-dev-toolkit.lib.mkLogicCheck {
              system = system;
              nixpkgs = nixpkgs;
              module = self.nixosModules.quadlet-collection;
              config = {
                config.services.nix-podman-appflowy-service = {
                  enable = true;
                  homeStateVersion = "25.05";
                  keyFile = "/tmp/dummy-key.txt";
                };
              };
            };

            test-caddy = nix-dev-toolkit.lib.mkLogicCheck {
              system = system;
              nixpkgs = nixpkgs;
              module = self.nixosModules.quadlet-collection;
              config = {
                config.services.nix-podman-caddy-quadlet = {
                  enable = true;
                  homeStateVersion = "25.05";
                };
              };
            };

            test-chia = nix-dev-toolkit.lib.mkLogicCheck {
              system = system;
              nixpkgs = nixpkgs;
              module = self.nixosModules.quadlet-collection;
              config = {
                config.services.nix-podman-chia-service = {
                  enable = true;
                  homeStateVersion = "25.05";
                  keyFile = "/tmp/dummy-key.txt";
                };
              };
            };

            test-mmx = nix-dev-toolkit.lib.mkLogicCheck {
              system = system;
              nixpkgs = nixpkgs;
              module = self.nixosModules.quadlet-collection;
              config = {
                config.services.nix-podman-mmx-service = {
                  enable = true;
                  homeStateVersion = "25.05";
                  keyFile = "/tmp/dummy-key.txt";
                };
              };
            };

            test-nicehash-nvidia = nix-dev-toolkit.lib.mkLogicCheck {
              system = system;
              nixpkgs = nixpkgs;
              module = self.nixosModules.quadlet-collection;
              config = {
                config.services.nix-podman-nicehash-service = {
                  workerName = "main-pc";
                  enable = false;
                  nvidia = true;
                  amd = false;
                  homeStateVersion = "25.05";
                };
              };
            };

            test-nicehash-amd = nix-dev-toolkit.lib.mkLogicCheck {
              system = system;
              nixpkgs = nixpkgs;
              module = self.nixosModules.quadlet-collection;
              config = {
                config.services.nix-podman-nicehash-service = {
                  workerName = "main-pc";
                  enable = false;
                  nvidia = false;
                  amd = true;
                  homeStateVersion = "25.11";
                };
              };
            };

            test-sshServerJohannes = nix-dev-toolkit.lib.mkLogicCheck {
              system = system;
              nixpkgs = nixpkgs;
              module = self.nixosModules.quadlet-collection;
              config = {
                config.services.nix-podman-sshServerJohannes-service = {
                  enable = true;
                  homeStateVersion = "25.05";
                };
              };
            };

            test-testServer = nix-dev-toolkit.lib.mkLogicCheck {
              system = system;
              nixpkgs = nixpkgs;
              module = self.nixosModules.quadlet-collection;
              config = {
                config.services.nix-podman-testServer-service = {
                  enable = true;
                  homeStateVersion = "25.05";
                };
              };
            };

          };

        in
        baseChecks // logicTests
      );

      devShells = nix-dev-toolkit.devShells;

      nixosModules = {
        quadlet-collection = {
          imports = [
            appflowy.nixosModules.service
            caddy.nixosModules.quadlet
            chia.nixosModules.service
            nicehash.nixosModules.service
            mmx.nixosModules.service
            sshServerJohannes.nixosModules.service
            testServer.nixosModules.service
          ];
        };
      };
    };
}
