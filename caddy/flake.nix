# Nix-podman-caddy-quadlet

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  };
  outputs = { nixpkgs, ... }@attrs: {
    nixosModules.quadlet = { config, lib, pkgs, ... }: {

      config = {
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
              publishPorts = [ "80:80" "443:443" "443:443/udp" ];
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
