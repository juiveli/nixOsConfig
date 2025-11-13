{
  inputs = {
    # ...
    nix-flatpak.url = "github:gmodena/nix-flatpak"; # unstable branch. Use github:gmodena/nix-flatpak/?ref=<tag> to pin releases.

    nix-template-config = {
      url = "github:juiveli/nix-template-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  };

  outputs =
    {
      self,
      nix-flatpak,
      nix-template-config,
      ...
    }:

    {
      nixosModules = {
        nixos-test-specific =
          { pkgs, config, ... }:
          {
            imports = [
              # Include the results of the hardware scan.
              ./hardware-configuration.nix
              nix-flatpak.nixosModules.nix-flatpak
              nix-template-config.nixosModules.nixos-fundamentals
            ];

            system.stateVersion = "24.11";
            #TODO CHANGE THIS
            custom.desktop-environment.gnome.enable = true;

            networking.hostName = "nixos-test"; # Define your hostname.

            system.autoUpgrade.enable = false;
            system.autoUpgrade.allowReboot = false;

            # Enable OpenGL
            hardware.graphics = {
              enable = true;
            };

            # Load nvidia driver for Xorg and Wayland
            services.xserver.videoDrivers = [ "nvidia" ];
            hardware.nvidia-container-toolkit.enable = true;
            hardware.nvidia = {

              # Modesetting is required.
              modesetting.enable = true;

              # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
              # Enable this if you have graphical corruption issues or application crashes after waking
              # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
              # of just the bare essentials.
              powerManagement.enable = false;

              # Fine-grained power management. Turns off GPU when not in use.
              # Experimental and only works on modern Nvidia GPUs (Turing or newer).
              powerManagement.finegrained = false;

              # Use the NVidia open source kernel module (not to be confused with the
              # independent third-party "nouveau" open source driver).
              # Support is limited to the Turing and later architectures. Full list of
              # supported GPUs is at:
              # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
              # Only available from driver 515.43.04+
              # Currently alpha-quality/buggy, so false is currently the recommended setting.
              open = false;

              # Enable the Nvidia settings menu,
              # accessible via `nvidia-settings`.
              nvidiaSettings = true;

              # Optionally, you may need to select the appropriate driver version for your specific GPU.
              package = config.boot.kernelPackages.nvidiaPackages.stable;
            };

            services.flatpak.enable = true;

            services.flatpak.packages = [
              {
                appId = "org.signal.Signal";
                origin = "flathub";
              }
              {
                appId = "com.heroicgameslauncher.hgl";
                origin = "flathub";
              }
            ];

            environment.systemPackages = [
              pkgs.element-desktop
              pkgs.phoronix-test-suite
              pkgs.unigine-heaven
            ];

            programs.steam = {
              enable = true;
              remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
              dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
              localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
            };
          };
      };
    };
}
