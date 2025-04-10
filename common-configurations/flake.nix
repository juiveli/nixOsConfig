{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    packages = {
      url = "./packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      packages,
    }@attrs:
    {
      nixosModules = {
        conffi =
          {
            config,
            lib,
            pkgs,
            ...
          }:
          {

            imports = [
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.joonas = import ./home-manager-users/joonas/home.nix;

              }
              packages.nixosModules.packages
            ];

            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
            ];

            # Bootloader.
            boot.loader = lib.mkDefault {
              systemd-boot.enable = true;
              efi.canTouchEfiVariables = true;
            };

            # Enable networking
            networking.networkmanager.enable = true;

            # Set your time zone.
            time.timeZone = "Europe/Helsinki";

            # Select internationalisation properties.
            i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

            i18n.extraLocaleSettings = lib.mkDefault {
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

            services.xserver = lib.mkDefault {
              # Enable the X11 windowing system.
              # You can disable this if you're only using the Wayland session.
              enable = true;

              # Enable Gnome Desktop Environment
              # services.xserver.displayManager.gdm.enable = true;
              desktopManager.gnome.enable = true;
              excludePackages = [ pkgs.xterm ]; # xterm comes with gnome

              # Configure keymap in X11
              xkb = {
                layout = "fi";
                variant = "";
              };

            };

            # Configure console keymap
            console.keyMap = "fi";

            # Disable unnecessary gnome packages ...
            services.gnome.core-utilities.enable = false;
            environment.gnome.excludePackages = with pkgs; [
              gnome-tour # GNOME Shell detects the .desktop file on first log-in.
              gnome-shell-extensions # This a collection of extensions.
            ];
            documentation.nixos.enable = false; # I can google it...

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
