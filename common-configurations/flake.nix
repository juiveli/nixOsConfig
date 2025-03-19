{
  inputs = {
    # ...
    #nix-flatpak.url =
    #  "github:gmodena/nix-flatpak"; # unstable branch. Use github:gmodena/nix-flatpak/?ref=<tag> to pin releases.
  };

  outputs = { self }: {
    nixosModules = {
      conffi = { config, pkgs, ... }: {

        nix.settings.experimental-features = [ "nix-command" "flakes" ];

        # Bootloader.
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        # Enable networking
        networking.networkmanager.enable = true;

        # Set your time zone.
        time.timeZone = "Europe/Helsinki";

        # Select internationalisation properties.
        i18n.defaultLocale = "en_US.UTF-8";

        i18n.extraLocaleSettings = {
          LC_ADDRESS = "fi_FI.UTF-8";
          LC_IDENTIFICATION = "fi_FI.UTF-8";
          LC_MEASUREMENT = "fi_FI.UTF-8";
          LC_MONETARY = "fi_FI.UTF-8";
          LC_NAME = "fi_FI.UTF-8";
          LC_NUMERIC = "fi_FI.UTF-8";
          LC_PAPER = "fi_FI.UTF-8";
          LC_TELEPHONE = "fi_FI.UTF-8";
          LC_TIME = "fi_FI.UTF-8";
        };

        # Enable the X11 windowing system.
        # You can disable this if you're only using the Wayland session.
        services.xserver.enable = true;

        # Enable Gnome Desktop Environment
        # services.xserver.displayManager.gdm.enable = true;
        services.xserver.desktopManager.gnome.enable = true;

        environment.gnome.excludePackages = with pkgs; [
          orca
          evince
          file-roller
          geary
          gnome-disk-utility
          seahorse
          sushi
          sysprof
          # gnome-shell-extensions
          # adwaita-icon-theme
          # gnome-backgrounds
          gnome-bluetooth
          # gnome-color-manager
          
          # Settings app
          # gnome-control-center
          gnome-tour # GNOME Shell detects the .desktop file on first log-in.
          gnome-user-docs
          glib # for gsettings program
          gnome-menus
          gtk3.out # for gtk-launch program
          # xdg-user-dirs # Update user dirs as described in https://freedesktop.org/wiki/Software/xdg-user-dirs/
          # xdg-user-dirs-gtk # Used to create the default bookmarks
          
          baobab
          epiphany
          gnome-text-editor
          gnome-calculator
          gnome-calendar
          gnome-characters
          gnome-clocks
          gnome-console
          gnome-contacts
          gnome-font-viewer
          gnome-logs
          gnome-maps
          gnome-music
          gnome-system-monitor
          gnome-weather
          loupe
          nautilus
          gnome-connections
          simple-scan
          snapshot
          totem
          yelp
          gnome-software
                  ];

        # xterm comes with gnome
        services.xserver.excludePackages = [ pkgs.xterm ];

        # Configure keymap in X11
        services.xserver.xkb = {
          layout = "fi";
          variant = "";
        };

        # Configure console keymap
        console.keyMap = "fi";

        # Enable CUPS to print documents.
        services.printing.enable = true;

        # Enable sound with pipewire.
        hardware.pulseaudio.enable = false;
        security.rtkit.enable = true;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          # If you want to use JACK applications, uncomment this
          #jack.enable = true;

          # use the example session manager (no others are packaged yet so this is enabled by default,
          # no need to redefine it in your config for now)
          #media-session.enable = true;
        };

        # Enable touchpad support (enabled default in most desktopManager).
        # services.xserver.libinput.enable = true;

        # Define a user account. Don't forget to set a password with ‘passwd’.
        users.users.joonas = {
          isNormalUser = true;
          description = "joonas";
          extraGroups = [ "networkmanager" "wheel" ];
          packages = with pkgs;
            [
              #  thunderbird
            ];
        };

        # Enable automatic login for the user. Do note that keyring password must be empty for it to open in autologin
        services.displayManager.autoLogin.enable = true;
        services.displayManager.autoLogin.user = "joonas";

        # Install firefox.
        programs.firefox.enable = true;

        # Allow unfree packages
        nixpkgs.config.allowUnfree = true;

        # List packages installed in system profile. To search, run:
        # $ nix search wget
        environment.systemPackages = with pkgs;
          [
            pkgs.git   # git is required for flakes support
            pkgs.nemo-with-extensions # file-manager
            pkgs.alacritty # terminal
            pkgs.gnomeExtensions.dash-to-panel # taskbar
            pkgs.gnomeExtensions.quick-settings-audio-panel # app specific audio, and mic slider
            pkgs.pulseaudio # required for audio panel
            # The Nano editor is also installed by default.
            #  wget
          ];

        virtualisation.containers.enable = true;
        virtualisation = {
          podman = {
            enable = true;
            # Create a `docker` alias for podman, to use it as a drop-in replacement
            dockerCompat = false;
            # Required for containers under podman-compose to be able to talk to each other.
            defaultNetwork.settings.dns_enabled = true;
          };
        };

        

        # This value determines the NixOS release from which the default
        # settings for stateful data, like file locations and database versions
        # on your system were taken. It‘s perfectly fine and recommended to leave
        # this value at the release version of the first install of this system.
        # Before changing this value read the documentation for this option
        # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
        system.stateVersion = "24.11"; # Did you read the comment?
      };
    };
  };
}

