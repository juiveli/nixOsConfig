# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../common-configurations/configuration.nix
    ../../common-configurations/nvidia-drivers.nix
    ./custom-folders.nix
    ./systemd-timers.nix
  ];
  networking.hostName = "main-pc"; # Define your hostname.
  services.nvidia-drivers.enable = true;

  services.custom-folders.enable = true;

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = false;
}
