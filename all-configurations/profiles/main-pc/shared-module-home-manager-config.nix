{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {
    # Podman quadlet enables
    services.nix-podman-chia-quadlet.enable = true;
    services.nix-podman-mmx-quadlet.enable = true;
    services.nix-podman-testServer-quadlet.enable = true;
    services.nix-podman-appflowy-quadlet.enable = true;
    services.nix-podman-sshServerJohannes-quadlet.enable = true;
    services.nix-podman-nicehash-quadlet = {
      workerName = "main-pc";
      enable = false;
      nvidia = true;
      amd = false;
    };

    custom.gnome.dconfSettings.enable = true;

  };
}
