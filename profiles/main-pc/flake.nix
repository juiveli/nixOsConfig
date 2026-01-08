# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  inputs = {

    dns-ip-updater = {
      url = "github:juiveli/nixOsConfig?dir=sharedModules/dns-ip-updater";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.sops-nix.follows = "sops-nix";
    };

    fundamentals = {
      url = "github:juiveli/nixOsConfig?dir=sharedModules/fundamentals";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak"; # unstable branch. Use github:gmodena/nix-flatpak/?ref=<tag> to pin releases.

    nix-gnome-configs = {
      url = "github:juiveli/nix-gnome-configs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    melonDS = {
      url = "github:melonDS-emu/melonDS";
    };

    podman-quadlets = {
      url = "github:juiveli/nixOsConfig?dir=sharedModules/podman-quadlets";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.quadlet-nix.follows = "quadlet-nix";
      inputs.sops-nix.follows = "sops-nix";
    };

    nix-wfinfo = {
      url = "path:/home/joonas/Documents/wfinfo-ng";
    };

    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      dns-ip-updater,
      fundamentals,
      home-manager,
      melonDS,
      nix-flatpak,
      nix-gnome-configs,
      nixpkgs,
      nix-wfinfo,
      podman-quadlets,
      ...
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
              dns-ip-updater.nixosModules.quadlet
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
              }
              podman-quadlets.nixosModules.quadlet-collection
              nix-flatpak.nixosModules.nix-flatpak

              fundamentals.nixosModules.nixos-fundamentals

            ];

            system.stateVersion = "24.11";

            custom.desktop-environment.gnome.enable = true;

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
                  nix-gnome-configs.homeManagerModules.nix-gnome-home-configs
                  ./homeManagerModules/sshfs.nix
                ];

                custom.gnome.dconfSettings.enable = true;

                home.stateVersion = "24.11";

              };

            boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

            networking.hostName = "main-pc"; # Define your hostname.

            # Open ports in the firewall.
            networking.firewall.allowedTCPPorts = [
              80
              443
              3030 # Heroes3
              17693 # Johanneksen ssh-server
            ];
            networking.firewall.allowedUDPPorts = [
              80
              443
            ];

            # Or disable the firewall altogether.
            networking.firewall.enable = true;

            services.mount-points.enable = true;

            services.dns-ip-updater.dy-fi = {
              enable = true;
            };

            services.nix-podman-appflowy-service = {
              enable = true;
              homeStateVersion = "25.05";
            };
            services.nix-podman-caddy-quadlet = {
              enable = true;
              homeStateVersion = "25.11";
            };
            services.nix-podman-chia-service = {
              enable = true;
              homeStateVersion = "25.11";
            };
            services.nix-podman-mmx-service = {
              enable = true;
              homeStateVersion = "25.11";
            };
            services.nix-podman-nicehash-service = {
              workerName = "main-pc";
              enable = false;
              nvidia = true;
              amd = false;
              homeStateVersion = "25.11";
            };
            services.nix-podman-testServer-service = {
              enable = true;
              homeStateVersion = "25.11";
            };
            services.nix-podman-sshServerJohannes-service = {
              enable = true;
              homeStateVersion = "25.11";
            };

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

              {
                appId = "io.appflowy.AppFlowy";
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

              pkgs.bolt-launcher # runescape launcher
              pkgs.mkvtoolnix

              pkgs.element-desktop
              # Minecraft custom launcher
              (pkgs.prismlauncher.override {
                # Add binary required by some mod
                additionalPrograms = [ pkgs.ffmpeg ];

                # Change Java runtimes available to Prism Launcher
                jdks = [
                  pkgs.graalvmPackages.graalvm-ce
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
              pkgs.runelite
              pkgs.sops
              pkgs.sshfs
              pkgs.steam-run
              melonDS.packages.${pkgs.stdenv.hostPlatform.system}.default
              nix-wfinfo.packages.${pkgs.stdenv.hostPlatform.system}.default
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
