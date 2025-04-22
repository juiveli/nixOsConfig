# Nix-podman-testServer-quadlet
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
          cfg = config.services.nix-podman-testServer-quadlet;
        in
        {

          options.services.nix-podman-testServer-quadlet = {
            enable = lib.mkEnableOption "nix-podman-testServer-quadlet";
          };

          config = lib.mkIf cfg.enable {
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
