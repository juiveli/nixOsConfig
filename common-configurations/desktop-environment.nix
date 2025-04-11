{ lib, pkgs, ... }:

{
  services.xserver = lib.mkDefault {
    enable = true;
    desktopManager.gnome.enable = true;
    excludePackages = [ pkgs.xterm ]; # Exclude xterm
    xkb = {
      layout = "fi";
      variant = "";
    };
  };

  # Disable unnecessary gnome packages ...
  services.gnome.core-utilities.enable = false;
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour # GNOME Shell detects the .desktop file on first log-in.
    gnome-shell-extensions # This a collection of extensions.
  ];
  documentation.nixos.enable = false; # I can google it...

  console.keyMap = "fi";
}
