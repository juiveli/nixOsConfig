{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {

    # Folder creations
    services.nix-podman-chia-quadlet.folder-creations.enable = true;
    services.nix-podman-mmx-quadlet.folder-creations.enable = true;
    # testServer does not need folders to be created
    # nicehash does not need folder to be created

    services.dns-ip-updater.dy-fi.enable = true;
    services.nix-podman-caddy-quadlet.enable = true;

    custom.desktop-environment.gnome.enable = true;

  };
}
