# Nix-podman-caddy-quadlet

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  };
  outputs =
    { nixpkgs, ... }@attrs:
    {
      homeManagerModules.quadlet =
        {
          config,
          lib,
          pkgs,
          ...
        }:

        let

          cfg = config.services.nix-podman-caddy-quadlet;
        in
        {

          options.services.nix-podman-caddy-quadlet = {
            enable = lib.mkEnableOption "nix-podman-caddy-quadlet";
          };

          config = lib.mkIf cfg.enable {
            systemd.user.startServices = "sd-switch";

            virtualisation.quadlet.containers = {
              caddy = {
                autoStart = true;
                serviceConfig = {
                  RestartSec = "10";
                  Restart = "always";
                };

                containerConfig = {
                  image = "docker.io/library/caddy:latest";
                  networks = [ "host" ];
                  publishPorts = [
                    "80:80"
                    "443:443"
                    "443:443/udp"
                  ];
                  volumes = [
                    "/var/lib/containers/caddy/Caddyfile:/etc/caddy/Caddyfile"
                    "/var/lib/containers/caddy/srv:/srv"
                    "/var/lib/containers/caddy/caddy_data:/data"
                    "/var/lib/containers/caddy/caddy_config:/config"
                  ];
                };
              };
            };
          };
        };

      nixosModules.quadlet =
        {
          config,
          lib,
          pkgs,
          ...
        }:

        let

          cfg = config.services.nix-podman-caddy-quadlet;
        in
        {

          options.services.nix-podman-caddy-quadlet = {
            folder-creations.enable = lib.mkEnableOption "nix-podman-caddy-quadlet.folder-creations";
            username = lib.mkOption {
              type = lib.types.str;
              default = "joonas";
            };
            usergroup = lib.mkOption {
              type = lib.types.str;
              default = "users";
            };
          };

          config = lib.mkIf cfg.folder-creations.enable {

            systemd.tmpfiles.settings = {
              "containers_folder" = {
                "/var/lib/containers" = {

                  d = {
                    group = cfg.usergroup;
                    mode = "0755";
                    user = cfg.username;
                  };
                };
              };

              "caddy_folders" = {

                "/var/lib/containers/caddy" = {
                  d = {
                    group = cfg.usergroup;
                    mode = "0755";
                    user = cfg.username;
                  };
                };

                "/var/lib/containers/caddy/srv" = {
                  d = {
                    group = cfg.usergroup;
                    mode = "0755";
                    user = cfg.username;
                  };
                };

                "/var/lib/containers/caddy/caddy_data" = {
                  d = {
                    group = cfg.usergroup;
                    mode = "0755";
                    user = cfg.username;
                  };
                };

                "/var/lib/containers/caddy/caddy_config" = {
                  d = {
                    group = cfg.usergroup;
                    mode = "0755";
                    user = cfg.username;
                  };
                };
              };
            };
          };
        };
    };
}
