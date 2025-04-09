{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
    }@attrs:
    {
      nixosModules = {
        conffi =
          { config, pkgs, ... }:
          {

            imports = [
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.joonas = import ./home-manager-users/joonas/home.nix;

              }
            ];

            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
            ];

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

            services.gnome.core-utilities.enable = false;

            environment.gnome.excludePackages = with pkgs; [
              gnome-tour # GNOME Shell detects the .desktop file on first log-in.
              gnome-shell-extensions # This a collection of extensions.
            ];

            services.xserver.excludePackages = [ pkgs.xterm ]; # xterm comes with gnome
            documentation.nixos.enable = false; # I can google it...

            # Configure keymap in X11
            services.xserver.xkb = {
              layout = "fi";
              variant = "";
            };

            # Configure console keymap
            console.keyMap = "fi";

            # Enable sound with pipewire.
            hardware.pulseaudio.enable = false;
            security.rtkit.enable = true;
            services.pipewire = {
              enable = true;
              alsa.enable = true;
              alsa.support32Bit = true;
              pulse.enable = true;
            };

            # Define a user account. Don't forget to set a password with ‘passwd’.
            users.users.joonas = {
              isNormalUser = true;
              description = "joonas";
              extraGroups = [
                "networkmanager"
                "wheel"
              ];
              packages = with pkgs; [
              ];
            };

            # Enable automatic login for the user. Do note that keyring password must be empty for it to open in autologin
            services.displayManager.autoLogin.enable = true;
            services.displayManager.autoLogin.user = "joonas";

            system.tools.nixos-option.enable = true;

            # Allow unfree packages
            nixpkgs.config.allowUnfree = true;

            programs.firefox.enable = true;

            programs.dconf.enable = true;

            # List packages installed in system profile. To search, run:
            # $ nix search wget
            environment.systemPackages = with pkgs; [
              pkgs.vscodium
              pkgs.git # git is required for flakes support
              pkgs.nemo-with-extensions # file-manager
              pkgs.alacritty # terminal
              pkgs.dconf2nix
              # The Nano editor is also installed by default.
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
