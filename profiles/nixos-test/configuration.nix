# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../common-configurations/configuration.nix
    ../../common-configurations/nvidia-drivers.nix
  ];
  networking.hostName = "nixos-test"; # Define your hostname.
  services.nvidia-drivers.enable = true;

  system.autoUpgrade.enable = false;
  system.autoUpgrade.allowReboot = false;
}
