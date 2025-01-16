{ lib, pkgs, config, ... }:
with lib;
let
  # Shorter name to access final settings a
  # user of hello.nix module HAS ACTUALLY SET.
  # cfg is a typical convention.
  cfg = config.services.podman-containers;
in {
  options.services.podman-containers = {
    enable = mkEnableOption "podman-containers";
  };

  config = mkIf cfg.enable {

    # Enable common container config files in /etc/containers (aka podman)
    virtualisation.containers.enable = true;
    virtualisation = {
      podman = {
        enable = true;
        # Create a `docker` alias for podman, to use it as a drop-in replacement
        dockerCompat = false;
        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
      };
    };
  };
}
