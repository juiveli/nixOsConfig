{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {

    home.stateVersion = "25.05";

    # Podman quadlet enables
    services.nix-podman-testServer-quadlet.enable = true;
  };
}
