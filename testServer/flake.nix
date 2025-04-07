# Nix-podman-testServer-quadlet
{
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };
  outputs = { nixpkgs, ... }@attrs: {
    nixosModules.quadlet = { config, lib, pkgs, ... }: {
      config = {
        systemd.user.startServices = "sd-switch";

        virtualisation.quadlet.containers = {
          testServer = {
            autoStart = true;
            serviceConfig = {
              RestartSec = "10";
              Restart = "always";
            };
            containerConfig = {
              image = "quay.io/libpod/banner:latest";
              publishPorts = [ "8001:80" ];
            };
          };
        };
      };
    };
  };
}
