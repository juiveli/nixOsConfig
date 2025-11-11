{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {
    # Podman quadlet enables
    services.nix-podman-testServer-quadlet.enable = true;
  };
}
