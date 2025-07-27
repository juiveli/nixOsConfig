# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  inputs = {
    # ...
    nix-flatpak.url = "github:gmodena/nix-flatpak"; # unstable branch. Use github:gmodena/nix-flatpak/?ref=<tag> to pin releases.

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-router-functionalities.url = "github:juiveli/nix-router-functionalities";

    melonDS = {
      url = "github:melonDS-emu/melonDS";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      nix-flatpak,
      nixpkgs,
      nix-router-functionalities,
      melonDS,
      sops-nix,
    }:

    {
      nixosModules = {
        main-pc-specific =
          {
            pkgs,
            config,
            lib,
            ...
          }:
          {
            imports = [
              # Include the results of the hardware scan.
              ./nixosModules/hardware-configuration.nix
              ./nixosModules/mount-points.nix
              nix-flatpak.nixosModules.nix-flatpak
              nix-router-functionalities.nixosModules.dhcp
              sops-nix.nixosModules.sops

            ];

            users.users.joonas = {
              # ...
              # required for auto start before user login
              linger = true;
              # required for rootless container with multiple users
              autoSubUidGidRange = true;
              uid = 1000;
            };

            home-manager.users.joonas =
              {
                pkgs,
                config,
                lib,
                ...
              }:
              {
                imports = [
                  sops-nix.homeManagerModules.sops
                  ./homeManagerModules/sshfs.nix
                ];

                sops.defaultSopsFile = ./secrets/rootless.yaml;
                sops.defaultSopsFormat = "yaml";
                sops.age.keyFile = "/home/joonas/.config/sops/age/keys.txt";

                sops.secrets.nonRootTest = { };
                sops.secrets.kakkonen = { };
              };

            sops.defaultSopsFile = ./secrets/root.yaml;
            sops.defaultSopsFormat = "yaml";
            sops.age.keyFile = "/home/joonas/.config/sops/age/keys.txt";

            sops.secrets.kakkosavain = { };

            boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

            networking.hostName = "main-pc"; # Define your hostname.

            # Open ports in the firewall.
            networking.firewall.allowedTCPPorts = [
              80
              443
              3030 # Heroes3
              47984 # Sunshine
              47989 # Sunshine
              47990 # Sunshine
              48010 # Sunshine
              64541
            ];
            networking.firewall.allowedUDPPorts = [
              80
              443

              # sunshine ports
              8000
              8001
              8002
              8003
              8004
              8005
              8006
              8007
              8008
              8009
              8010
              47998
              47999
              48000

              64541
            ];

            # Or disable the firewall altogether.
            networking.firewall.enable = true;

            services.mount-points.enable = true;

            system.autoUpgrade.enable = true;
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

            # LACT need this
            environment.sessionVariables = {
              LD_LIBRARY_PATH = "/run/opengl-driver/lib";
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
              {
                appId = "eu.vcmi.VCMI";
                origin = "flathub";
              }

            ];

            services.avahi.publish.enable = true;

            services.sunshine = {
              enable = true;
              autoStart = true;
              capSysAdmin = true; # only needed for Wayland -- omit this when using with Xorg
              openFirewall = true;
            };

            environment.systemPackages = [
              pkgs.mkvtoolnix

              pkgs.element-desktop
              # Minecraft custom launcher
              (pkgs.prismlauncher.override {
                # Add binary required by some mod
                additionalPrograms = [ pkgs.ffmpeg ];

                # Change Java runtimes available to Prism Launcher
                jdks = [
                  pkgs.graalvm-ce
                  pkgs.zulu8
                  pkgs.zulu17
                  pkgs.zulu
                ];
              })
              pkgs.transmission_4-qt6
              pkgs.vlc
              pkgs.inkscape-with-extensions
              pkgs.pinta
              pkgs.nvidia-container-toolkit
              pkgs.sops
              pkgs.sshfs
              melonDS.packages.${pkgs.system}.default
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
