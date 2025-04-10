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
          {
            # Enable sound with Pipewire.
            hardware.pulseaudio.enable = false;
            security.rtkit.enable = true;
            services.pipewire = {
              enable = true;
              alsa.enable = true;
              alsa.support32Bit = true;
              pulse.enable = true;
            };

            # Allow unfree packages.
            nixpkgs.config.allowUnfree = true;

            # Enable programs.
            programs.firefox.enable = true;
            programs.dconf.enable = true;

            # List packages installed in the system profile.
            environment.systemPackages = with pkgs; [
              pkgs.vscodium
              pkgs.git
              pkgs.nemo-with-extensions
              pkgs.alacritty
              pkgs.dconf2nix
            ];

            # Virtualization settings.
            virtualisation.containers.enable = true;
            virtualisation.podman = {
              enable = true;
              dockerCompat = false;
              defaultNetwork.settings.dns_enabled = true;
            };
          };
      };
    };
}
