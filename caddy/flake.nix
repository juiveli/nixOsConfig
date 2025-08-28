{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    
    hugo-blog = {
      url = "github:juiveli/hugo-blog";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hugo-mainsite = {
      url = "github:juiveli/main-website";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
  };

  outputs =
    { self, nixpkgs, home-manager, hugo-blog, hugo-mainsite, quadlet-nix, ... }@attrs:
    let
      system = "x86_64-linux";
      # It's cleaner to import pkgs here
      pkgs = import nixpkgs { inherit system; };
    in
    {
      nixosModules.quadlet =
        { config, lib, ... }:
        let
          cfg = config.services.nix-podman-caddy-quadlet;
        in
        {
          options.services.nix-podman-caddy-quadlet = {
            enable = lib.mkEnableOption "nix-podman-caddy-quadlet";
          };


          imports = [ quadlet-nix.nixosModules.quadlet ];

          config = lib.mkIf cfg.enable
          {

            
            
            users.groups.caddy = {};
            users.users.caddy = {
              isNormalUser = true;
              group = "caddy";
              description = "Caddy web server";
              home = "/var/lib/containers/caddy";
              createHome = true;
              linger = true;
              autoSubUidGidRange = true;
            };

            systemd.tmpfiles.settings = {
              "containers_folder" = {
                "/var/lib/containers" = {
                  d = {

                  };
                };
              };
              "caddy_folders" = {
                "/var/lib/containers/caddy" = {
                  d = {
                    group = "caddy";
                    mode = "0775";
                    user = "caddy";
                  };
                };
                "/var/lib/containers/caddy/srv" = {
                  d = {
                    group = "caddy";
                    mode = "0775";
                    user = "caddy";
                  };
                };
                "/var/lib/containers/caddy/srv/hugo" = {
                  d = {
                    group = "caddy";
                    mode = "0775";
                    user = "caddy";
                  };
                };
                "/var/lib/containers/caddy/caddy_data" = {
                  d = {
                    group = "caddy";
                    mode = "0775";
                    user = "caddy";
                  };
                };
                "/var/lib/containers/caddy/caddy_config" = {
                  d = {
                    group = "caddy";
                    mode = "0775";
                    user = "caddy";
                  };
                };
              };
            };

            home-manager.users.caddy = {
                # Import the homeManagerModules from this same flake
                imports = [ self.homeManagerModules.quadlet quadlet-nix.homeManagerModules.quadlet ];
                # Enable the Home Manager module
                services.nix-podman-caddy-quadlet.enable = true;
                home.stateVersion = "25.05"; # Remove this when possible
              };
          };
        };

      homeManagerModules.quadlet =
        { config, lib, pkgs, ... }:
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

            systemd.user.services.hugo-update = {
              Unit = {
                Description = "Rebuild Hugo site";
                After = [ "network-online.target" ];
              };
              Service = {
                ExecStart = "${pkgs.hugo}/bin/hugo -d /var/lib/containers/caddy/srv/hugo --noBuildLock";
                WorkingDirectory = "${hugo-blog}";
                Restart = "always";
              };
              Install = {
                WantedBy = [ "default.target" ];
              };
            };

            systemd.user.timers.hugo-update = {
              Unit = {
                Description = "Run Hugo site update daily";
              };
              Timer = {
                OnCalendar = "daily";
                Persistent = true;
              };
              Install = {
                WantedBy = [ "timers.target" ];
              };
            };

            systemd.user.paths.hugo-source-watcher = {
              Unit = {
                Description = "Watch for changes to the Hugo site source.";
              };
              Path = {
                PathChanged = "${hugo-blog}";
                Service = "hugo-update.service";
              };
              Install = {
                WantedBy = [ "default.target" ];
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
    };
}