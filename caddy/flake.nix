# Nix-podman-caddy-quadlet

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    hugo-blog = {
      url = "/home/joonas/Documents/git-projects/hugo-blog";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hugo-mainsite = {
      url = "/home/joonas/Documents/git-projects/main-website";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
  outputs =
    {
      nixpkgs,
      hugo-blog,
      hugo-mainsite,
      ...
    }@attrs:

    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { system = system; };
    in
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

            home.packages = [ pkgs.hugo ];

            home.activation.hugoDeploy = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              echo "Deploying Hugo site from Nix store..."
              cp -r ${hugo-mainsite.packages.x86_64-linux.hugo-mainsite} /var/lib/containers/caddy/srv/mainpage
              chmod -R 775 /var/lib/containers/caddy/srv/mainpage
            '';

            systemd.user.services.hugo-update = {
              Unit = {
                Description = "Rebuild Hugo site";
                After = [ "network-online.target" ];
              };

              Service = {
                ExecStart = "/bin/sh -c 'cd ${hugo-blog} && hugo -d /var/lib/containers/caddy/srv/hugo --noBuildLock && chmod -R 775 /var/lib/containers/caddy/srv/hugo && chown -R joonas:users /var/lib/containers/caddy/srv/hugo'";
                WorkingDirectory = "/var/lib/containers/caddy/srv";
                Restart = "always";
              };

              Install = {
                WantedBy = [ "default.target" ]; # Enables it in user session
              };
            };

            systemd.user.timers.hugo-update = {
              Unit = {
                Description = "Run Hugo site update daily";
              };

              Timer = {
                OnCalendar = "daily"; # Runs Hugo site update every day
                Persistent = true;
              };

              Install = {
                WantedBy = [ "timers.target" ]; # Ensures it's active in user session
              };
            };

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

                "/var/lib/containers/caddy/srv/hugo" = {
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
