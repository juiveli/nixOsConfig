{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs =
    { self, nixpkgs, ... }:
    {
      # Define reusable modules in `nixosModules`.
      nixosModules = {
        packages =
          {
            config,
            lib,
            pkgs,
            ...
          }:

          let
            # Block for GUI packages
            guiConfig = lib.mkIf config.custom.packages.gui.enable {
              programs.firefox.enable = true;

              environment.systemPackages = [
                pkgs.vscodium
                pkgs.nemo-with-extensions
                pkgs.alacritty
              ];
            };

            # Block for GUI-less packages
            guilessConfig = lib.mkIf config.custom.packages.guiless.enable {
              hardware.pulseaudio.enable = false;
              security.rtkit.enable = true;
              services.pipewire = {
                enable = true;
                alsa.enable = true;
                alsa.support32Bit = true;
                pulse.enable = true;
              };

              virtualisation.containers.enable = true;
              virtualisation.podman = {
                enable = true;
                dockerCompat = false;
                defaultNetwork.settings.dns_enabled = true;
              };

              environment.systemPackages = [
                pkgs.git
                pkgs.dconf2nix
              ];
            };

          in

          {

            options = {
              custom.packages.gui.enable = lib.mkEnableOption "Enable GUI-based packages I think are necessary defaults.";
              custom.packages.guiless.enable = lib.mkEnableOption "Enable GUI-less packages I think are necessary defaults.";
            };

            # Merge everything into the config
            config = lib.mkMerge [
              {
                nixpkgs.config.allowUnfree = lib.mkDefault true;
              }
              guiConfig
              guilessConfig
            ];

          };
      };
    };
}
