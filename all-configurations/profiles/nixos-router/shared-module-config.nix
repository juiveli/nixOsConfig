{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {

    services.dns-ip-updater.dy-fi.enable = false;
    services.nix-podman-caddy-quadlet.enable = false;

  };
}
