{
  pkgs,
  lib,
  config,
  ...
}:

let

  cfg = config.custom.gnome.dconfSettings;
in

{

  options.custom.gnome.dconfSettings = {
    enable = lib.mkEnableOption "Custom GNOME dconf configurations.";
  };

  config = lib.mkIf cfg.enable {

    home.packages = [
      pkgs.gnomeExtensions.dash-to-panel # taskbar
      pkgs.gnomeExtensions.quick-settings-audio-panel # app specific audio, and mic slider
      pkgs.gnomeExtensions.arcmenu
      pkgs.pulseaudio # required for audio panel gnome extension
    ];

    dconf = {
      enable = true;
      settings = {
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

        "org/nemo/preferences" = {
          show-hidden-files = true;

        };

        "org/gnome/desktop/interface" = {
          cursor-theme = "Adwaita";
          font-name = "Noto Sans,  10";
          gtk-theme = "Adwaita";
          icon-theme = "breeze";
          scaling-factor = lib.hm.gvariant.mkUint32 1;
          toolbar-style = "text";
        };

        ##############################

        "org/gnome/shell" = {
          favorite-apps = [
            "Alacritty.desktop"
            "codium.desktop"
            "nemo.desktop"
            "firefox.desktop"
          ];
        };

        ################################
        # Wi-fi

        # Regular nix syntax can be used

        ################################
        # Network

        # Regular nix syntax can be used

        ################################
        # Bluetooth

        # Keep default settings

        #################################
        # Display

        "org/gnome/settings-daemon/plugins/color" = {
          night-light-enabled = false;
          night-light-schedule-automatic = false;
        };

        # Other settings default because can not know how many display etc.

        ############################################
        # Sound
        # Default should be fine (Mainly because right config settings could not be found)

        ################################
        # Power

        "org/gnome/desktop/session" = {
          idle-delay = lib.hm.gvariant.mkUint32 0;
        };

        "org/gnome/settings-daemon/plugins/power" = {
          sleep-inactive-ac-type = "nothing"; # Automatic suspend
          power-button-action = "interactive"; # Power button behaviour

        };

        #####################################
        # Multitasking
        "org/gnome/desktop/interface" = {
          enable-hot-corners = "false";
        };

        "org/gnome/mutter" = {
          edge-tiling = true; # Active Screen Edges
          dynamic-workspaces = true;
        };

        # Multi-Monitor default ( I did not understand what it do)
        # App Switching default ( I did not understand what it do)

        #################################
        # Appearance

        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };

        ###################################
        # Apps

        # Default apps
        "org/gnome/desktop/media-handling" = {
          autorun-never = true;
        }; # Media autostart

        # Default apps with regular nix syntax

        ###################################
        # Notifications

        "org/gnome/desktop/notifications" = {
          show-banners = true; # Do not disturb (true is off)
          show-in-lock-screen = true; # Lock screen notifications
        };

        ##################################
        # Search
        # Keep default

        ################################
        # @ Online accounts
        # Do with regular nix syntax if you wish

        # Sharing
        ###########################
        # Keep default, if change needed I'd prefer regular nix syntax

        ########################################

        # Mouse and touchpad
        "org/gnome/desktop/peripherals/mouse" = {
          left-handed = false;
          speed = 0.0;
          accel-profile = "default";
          natural-scroll = false;
        };

        ############################
        # Keyboard

        "org/gnome/desktop/input-sources" = {
          per-window = false;
        }; # Input source switching
        # Input sources can be handled by regular nix syntax

        #################################
        # Accessibility

        "org/gnome/desktop/interface" = {
          toolkit-accessibility = false;
        }; # Not menu item

        "org/gnome/desktop/a11y" = {
          always-show-universal-access-status = false;
        }; # Accessibility menu

        # Seeing

        "org/gnome/desktop/a11y/applications" = {
          screen-reader-enabled = false;
        };

        "org/gnome/desktop/a11y/interface" = {
          high-contrast = false;
          show-status-shapes = false; # On/off shapes
          overlay-scrolling = true; # Always Show Scrollbars
        };

        "org/gnome/desktop/a11y/keyboard" = {
          togglekeys-enable = false;
        };

        "org/gnome/desktop/interface" = {
          enable-animations = true;
          text-scaling-factor = 1.0;
          cursor-size = 24;
        };

        # Hearing
        "org/gnome/desktop/sound" = {
          allow-volume-above-100-percent = false;
        };
        "org/gnome/desktop/wm/preferences" = {
          visual-bell = false;
        }; # Visual alerts

        # Typing

        "org/gnome/desktop/a11y/applications" = {
          screen-keyboard-enabled = false;
        };

        "org/gnome/desktop/a11y/keyboard" = {
          enable = false; # Enable accessibility settigs with keyboard
          stickykeys-enable = false;
          slowkeys-enable = false;
          bouncekeys-enable = false;
        };

        "org/gnome/desktop/interface" = {
          cursor-blink = true;
          cursor-blink-time = 1200;
        };

        "org/gnome/desktop/peripherals/keyboard" = {
          repeat = true;
          repeat-interval = lib.hm.gvariant.mkUint32 30;
          delay = lib.hm.gvariant.mkUint32 500;
        };

        # Pointing and Clicking

        "org/gnome/desktop/a11y/keyboard" = {
          mousekeys-enable = false;
        };

        "org/gnome/desktop/a11y/mouse" = {
          secondary-click-enabled = false;
          dwell-click-enabled = false;
        };

        "org/gnome/desktop/interface" = {
          locate-pointer = false;
        };

        "org/gnome/desktop/wm/preferences" = {
          focus-mode = "click";
        }; # Activate Windows on hover

        "org/gnome/desktop/peripherals/mouse" = {
          double-click = 400;
        };

        # Zoom

        # Stick to defaults in Zoom options

        ###############################
        # Privacy and security
        # Keep defaults

        ##########################
        # System
        # Changes to System settings seem to be available trough regular nix syntax

        ######################################

        ######################################
        # Extensions

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
          search-entry-border-radius = lib.hm.gvariant.mkTuple [
            true
            25
          ];
          show-activities-button = false;
        };

        "org/gnome/shell/extensions/dash-to-panel" = {
          animate-appicon-hover = true;
          animate-appicon-hover-animation-extent = "{'RIPPLE': 4, 'PLANK': 4, 'SIMPLE': 1}";
          appicon-margin = 0;
          appicon-padding = 4;
          available-monitors = [ 0 ];
          dot-position = "LEFT";
          dot-style-focused = "METRO";
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
          multi-monitors = false; # It was hard to make config to be same on all displays
        };

        "org/gnome/shell/extensions/quick-settings-audio-panel" = {
          always-show-input-volume-slider = true;
          create-applications-volume-sliders = true;
          create-balance-slider = false;
          ignore-css = false;
          master-volume-sliders-show-current-device = true;
          version = 2;
        };

        ############################################

      };
    };
  };
}
