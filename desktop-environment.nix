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
      excludePackages = [ pkgs.xterm ]; # Exclude xterm
      xkb = lib.mkDefault {
        layout = "fi";
        variant = "";

      };
    };

    services.desktopManager.gnome.enable = true;
    services.displayManager.gdm.enable = true;
    services.displayManager.gdm.wayland = true;

    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;

    # Disable unnecessary gnome packages ...
    services.gnome.core-apps.enable = true;
    environment.gnome.excludePackages = [
      pkgs.gnome-tour # GNOME Shell detects the .desktop file on first log-in.
      pkgs.gnome-shell-extensions # This a collection of extensions.
    ];
    documentation.nixos.enable = false; # I can google it...

  };
}
