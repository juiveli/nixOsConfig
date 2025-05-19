{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.desktop-environment.gnome;

in
{

  options.custom.desktop-environment.gnome = {
    enable = lib.mkEnableOption "Enable gnome with fi as default keyboard that can be overriden";
  };

  config = lib.mkIf cfg.enable {

    services.xserver = {
      enable = true;
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;
      displayManager.gdm.wayland = true;

      excludePackages = [ pkgs.xterm ]; # Exclude xterm
      xkb = lib.mkDefault {
        layout = "fi";
        variant = "";

      };
    };

    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;

    # Disable unnecessary gnome packages ...
    services.gnome.core-utilities.enable = false;
    environment.gnome.excludePackages = [
      pkgs.gnome-tour # GNOME Shell detects the .desktop file on first log-in.
      pkgs.gnome-shell-extensions # This a collection of extensions.
    ];
    documentation.nixos.enable = false; # I can google it...

    console.keyMap = lib.mkDefault "fi";
  };
}
