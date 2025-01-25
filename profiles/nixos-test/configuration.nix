# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  # version 0.5.2
  nix-flatpak = (builtins.getFlake
    "github:gmodena/nix-flatpak/8bdc2540da516006d07b04019eb57ae0781a04b3");

in {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../common-configurations/configuration.nix
    ../../common-configurations/nvidia-drivers.nix
    nix-flatpak.nixosModules.nix-flatpak
  ];

  networking.hostName = "nixos-test"; # Define your hostname.
  services.nvidia-drivers.enable = true;

  system.autoUpgrade.enable = false;
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

  environment.systemPackages = [ pkgs.element-desktop ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall =
      true; # Open ports in the firewall for Steam Local Network Game Transfers
  };
}
