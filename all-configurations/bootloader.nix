{ lib, ... }:

{
  boot.loader = lib.mkDefault {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
}
