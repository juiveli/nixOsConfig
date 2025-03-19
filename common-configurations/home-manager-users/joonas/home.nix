{ pkgs, ... }:

{
  home.username = "joonas";
  home.homeDirectory = "/home/joonas";
  programs.home-manager.enable = true;
  home.stateVersion = "24.11";



  dconf = {
    enable = true;
    settings = 
    {
      "org/gnome/shell" = {
        disable-user-extensions = false; # enables user extensions
        enabled-extensions = [
          # Put UUIDs of extensions that you want to enable here.
          # If the extension you want to enable is packaged in nixpkgs,
          # you can easily get its UUID by accessing its extensionUuid
          # field (look at the following example).
          pkgs.gnomeExtensions.dash-to-panel.extensionUuid
          pkgs.gnomeExtensions.quick-settings-audio-panel.extensionUuid

          
        ];
      };
    

#  "org/gnome/desktop/interface" = {
#    color-scheme = "default";
#    cursor-size = 24;
#    cursor-theme = "breeze_cursors";
#    enable-animations = true;
#    font-name = "Noto Sans,  10";
#    gtk-theme = "Adwaita";
#    icon-theme = "breeze";
#    scaling-factor = mkUint32 1;
#    text-scaling-factor = 1.0;
#    toolbar-style = "text";
#  };
#
      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = false;
        night-light-schedule-automatic = false;
      };

      "org/gnome/settings-daemon/plugins/power" = {
        sleep-inactive-ac-type = "nothing";
      };

      "org/gnome/shell" = {
        favorite-apps = [ "Alacritty.desktop" "firefox.desktop" "codium.desktop" "nemo.desktop" ];
      };

      "org/gnome/shell/extensions/dash-to-panel" = {
        animate-appicon-hover = true;
        animate-appicon-hover-animation-extent = "{'RIPPLE': 4, 'PLANK': 4, 'SIMPLE': 1}";
        appicon-margin = 0;
        appicon-padding = 4;
        available-monitors = [ 0 ];
        dot-position = "LEFT";
        dot-style-unfocused = "DASHES";
        group-apps = true;
        hotkeys-overlay-combo = "TEMPORARILY";
        leftbox-padding = -1;
        panel-anchors = ''
          {"0":"MIDDLE"}
        '';
        panel-element-positions = ''
          {"0":[{"element":"showAppsButton","visible":true,"position":"stackedTL"},{"element":"activitiesButton","visible":true,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}]}
        '';
        panel-lengths = ''
          {"0":100}
        '';
        panel-positions = ''
          {"0":"TOP"}
        '';
        panel-sizes = ''
          {"0":32}
        '';
        primary-monitor = 0;
        show-favorites = true;
        show-favorites-all-monitors = true;
        show-running-apps = true;
        status-icon-padding = -1;
        tray-padding = -1;
        tray-size = 0;
        window-preview-title-position = "TOP";
      };

      "org/gnome/shell/extensions/quick-settings-audio-panel" = {
        always-show-input-volume-slider = true;
        create-applications-volume-sliders = true;
        create-balance-slider = false;
        ignore-css = false;
        master-volume-sliders-show-current-device = true;
        version = 2;
      };

      "org/nemo/preferences" = {
        show-hidden-files = true;
      };

      "org/nemo/window-state" = {
        geometry = "800x550+1041+305";
        maximized = false;
        sidebar-bookmark-breakpoint = 1;
        start-with-sidebar = true;
      };
    };
  };
}