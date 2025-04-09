# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  inputs = {
    # ...
    nix-flatpak.url = "github:gmodena/nix-flatpak"; # unstable branch. Use github:gmodena/nix-flatpak/?ref=<tag> to pin releases.

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Let's try different approach next version after 24.11, see https://github.com/hercules-ci/flake-parts/pull/251
    nix-podman-quadlet-collection = {
      url = "/home/joonas/Documents/git-projects/nix-podman-quadlet-collection";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      nix-flatpak,
      sops-nix,
      nix-podman-quadlet-collection,
      nixpkgs,
    }:

    {
      nixosModules = {
        conffi =
          { pkgs, config, ... }:
          {
            imports = [
              # Include the results of the hardware scan.
              ./hardware-configuration.nix
              ./custom-folders.nix
              ./systemd-timers.nix
              ./mount-points.nix
              nix-flatpak.nixosModules.nix-flatpak
              nix-podman-quadlet-collection.nixosModules.quadlet-collection
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
                systemd.user.startServices = "sd-switch";
                imports = [
                  nix-podman-quadlet-collection.homeManagerModules.quadlet-collection
                  sops-nix.homeManagerModules.sops
                ];
                # Nix quadlet activations:
                services.nix-podman-caddy-quadlet.enable = true;
                services.nix-podman-chia-quadlet.enable = true;
                services.nix-podman-mmx-quadlet.enable = true;
                services.nix-podman-testServer-quadlet.enable = true;
                services.nix-podman-nicehash-nvidia-quadlet = {
                  workerName = "main-pc";
                  enable = true;
                };

                sops.defaultSopsFile = ./secrets/rootless.yaml;
                sops.defaultSopsFormat = "yaml";
                sops.age.keyFile = "/home/joonas/.config/sops/age/keys.txt";

                sops.secrets.nonRootTest = { };
                sops.secrets.kakkonen = { };
              };

            # quadlet activations:
            services.nix-podman-caddy-quadlet.folder-creations.enable = true;
            services.nix-podman-chia-quadlet.folder-creations.enable = true;
            services.nix-podman-mmx-quadlet.folder-creations.enable = true;
            # testServer does not need folders to be created
            # nicehash does not need folder to be created

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
            ];
            networking.firewall.allowedUDPPorts = [
              80
              443
            ];
            # Or disable the firewall altogether.
            networking.firewall.enable = true;

            services.custom-folders.enable = true;
            services.mount-points.enable = true;
            services.systemd-timers.enable = true;

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
              pkgs.inkscape-with-extensions
              pkgs.pinta
              pkgs.nvidia-container-toolkit
              pkgs.sops
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
