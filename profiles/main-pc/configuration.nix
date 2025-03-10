# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  # version 0.5.2
  nix-flatpak = (builtins.getFlake
    "github:gmodena/nix-flatpak/8bdc2540da516006d07b04019eb57ae0781a04b3");
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../common-configurations/configuration.nix
    ../../common-configurations/nvidia-drivers.nix
    ./custom-folders.nix
    ./systemd-timers.nix
    ./mount-points.nix
    nix-flatpak.nixosModules.nix-flatpak

  ];

  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

  networking.hostName = "main-pc"; # Define your hostname.
  services.nvidia-drivers.enable = true;

  services.custom-folders.enable = true;
  services.mount-points.enable = true;
  services.systemd-timers.enable = true;

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = false;

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
      jdks = [ pkgs.graalvm-ce pkgs.zulu8 pkgs.zulu17 pkgs.zulu ];
    })
    pkgs.vscodium
    pkgs.inkscape-with-extensions
    pkgs.pinta
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall =
      true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 80 443 ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;
}
