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
          pkgs.gnomeExtensions.arcmenu.extensionUuid

          
        ];
      };
    

      "org/gnome/desktop/interface" = {
        enable-hot-corners = false;
        color-scheme = "default";
        cursor-size = 24;
        cursor-theme = "breeze_cursors";
        enable-animations = true;
        font-name = "Noto Sans,  10";
        gtk-theme = "Adwaita";
        icon-theme = "breeze";
        # scaling-factor = mkUint32 1;
        text-scaling-factor = 1.0;
        toolbar-style = "text";
      };

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
      
      "org/gnome/shell/extensions/arcmenu" = {
      force-menu-location = "Off";
      hide-overview-on-startup = false;
      dash-to-panel-standalone = false;
      menu-button-appearance = "Text_Icon";
      menu-button-position-offset = 1;
      menu-layout = "Tognee";
      menu-position-alignment = 41;
      multi-monitor = false;
      position-in-panel = "Left";
      prefs-visible-page = 0;
      # search-entry-border-radius = mkTuple [ true 25 ];
      show-activities-button = false;
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
          {"0":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}]}
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


    };
  };
}