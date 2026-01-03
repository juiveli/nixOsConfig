# nix-podman-sshServerJohannes-quadlet
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";

  };
  outputs =
    {
      self,
      home-manager,
      nixpkgs,
      quadlet-nix,
      ...
    }@attrs:
    {
      homeManagerModules.quadlet =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.services.nix-podman-sshServerJohannes-quadlet;
        in
        {

          options.services.nix-podman-sshServerJohannes-quadlet = {
            enable = lib.mkEnableOption "nix-podman-sshServerJohannes-quadlet";
          };

          config = lib.mkIf cfg.enable {
            systemd.user.startServices = "sd-switch";

            virtualisation.quadlet.containers = {
              sshServerJohannes = {
                autoStart = true;
                serviceConfig = {
                  RestartSec = "10";
                  Restart = "always";
                };
                containerConfig = {
                  environments = {
                    # We can not tell user puid or pgid before user is created.
                    # We could get around this by assigning puid and pgid manually when creating user, but decided not to
                    # PUID = 1005;
                    # PGID = 1005;
                    PUBLIC_KEY_DIR = "/pubkeys";
                    SUDO_ACCESS = "true";
                    PASSWORD_ACCESS = "false";
                    USER_NAME = "johannes";
                  };
                  image = "lscr.io/linuxserver/openssh-server:latest";
                  publishPorts = [ "17693:2222" ];

                  volumes = [
                    "/media/noob/config/:/config"
                    "/media/noob/system/:/system"
                    "/media/noob/data/:/data"
                    "/media/noob/pubkeys/:/pubkeys"
                  ];
                };
              };
            };
          };
        };

      nixosModules.folders =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let

          cfg = config.services.nix-podman-sshServerJohannes-infra;
        in
        {

          options.services.nix-podman-sshServerJohannes-infra = {
            enable = lib.mkEnableOption "sshServerJohannes directory structure";
            username = lib.mkOption { type = lib.types.str; };
            usergroup = lib.mkOption {
              type = lib.types.str;
              default = cfg.username;
            };
          };

          config = lib.mkIf cfg.enable {

            systemd.tmpfiles.settings = {

              "sshServerJohannes_folders" = {

                "/media/noob/config" = {
                  d = {
                    group = cfg.usergroup;
                    mode = "0700";
                    user = cfg.username;
                  };
                };

                "/media/noob/system/" = {
                  d = {
                    group = cfg.usergroup;
                    mode = "0700";
                    user = cfg.username;
                  };
                };

                "/media/noob/data" = {
                  d = {
                    group = cfg.usergroup;
                    mode = "0700";
                    user = cfg.username;
                  };
                };

                "/media/noob/pubkeys" = {
                  d = {
                    group = cfg.usergroup;
                    mode = "0700";
                    user = cfg.username;
                  };
                };

              };
            };

          };
        };

      nixosModules.service =
        { config, lib, ... }:
        let
          cfg = config.services.nix-podman-sshServerJohannes-service;
        in
        {
          options.services.nix-podman-sshServerJohannes-service = {
            enable = lib.mkEnableOption "sshServerJohannes Service User and HM setup";
            user = lib.mkOption {
              type = lib.types.str;
              default = "sshServerJohannes-user";
            };
          };

          imports = [
            self.nixosModules.folders
            home-manager.nixosModules.home-manager
            quadlet-nix.nixosModules.quadlet
          ];

          config = lib.mkIf cfg.enable {

            services.nix-podman-sshServerJohannes-infra = {
              enable = true;
              username = cfg.user;
            };

            users.groups.${cfg.user} = { };
            users.users.${cfg.user} = {
              isNormalUser = true;
              group = cfg.user;
              description = "Dedicated sshServerJohannes Service User";
              home = "/media/noob/sshServerJohannes";
              createHome = true;
              linger = true; # Required for Podman to run without login
            };

            home-manager.users.${cfg.user} = {
              imports = [
                self.homeManagerModules.quadlet
                quadlet-nix.homeManagerModules.quadlet
              ];

              services.nix-podman-sshServerJohannes-quadlet.enable = true;
            };
          };
        };
    };
}
