# Impermance config for folders
{
  inputs = {
    impermanence.url = "github:nix-community/impermanence";
    impermanence.inputs.nixpkgs.follows = "";
    impermanence.inputs.home-manager.follows = "";
  };

  outputs =
    {
      self,
      impermanence,
      ...
    }:
    {
      nixosModules.impermanence_folders =
        {
          config,
          lib,
          pkgs,
          ...
        }:

        let
          cfg = config.custom.impermanence_folders;

        in
        {

          options.custom.impermanence_folders = {
            enable = lib.mkEnableOption "impermanence folders";

          };

          imports = [
            impermanence.nixosModules.impermanence
          ];

          config = lib.mkIf cfg.enable {

            environment.persistence."/persist" = {

              hideMounts = true;

              directories = [
                "/var/log"
                "/var/lib/bluetooth"
                "/var/lib/nixos"
                "/var/lib/systemd/coredump"
                "/var/lib/systemd/timers"
                "/etc/NetworkManager/system-connections"

                {
                  directory = "/var/lib/colord";
                  user = "colord";
                  group = "colord";
                  mode = "u=rwx,g=rx,o=";
                }

              ];

              #files = [
              #  "/etc/machine-id"
              #  {
              #    file = "/etc/nix/id_rsa";
              #    parentDirectory = {
              #      mode = "u=rwx,g=,o=";
              #    };
              #  }
              # ];

            };
          };
        };

      nixosModules.impermanence_script =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let

          cfg = config.custom.impermanence_script;
        in
        {

          options.custom.impermanence_script = {
            enable = lib.mkEnableOption "delete /root subvolume that are more than 30 days old";
          };

          config = lib.mkIf cfg.enable {

            boot.initrd.postResumeCommands = lib.mkAfter ''
              mkdir /btrfs_tmp
              mount /dev/disk/by-label/nixos /btrfs_tmp
              if [[ -e /btrfs_tmp/root ]]; then
                  mkdir -p /btrfs_tmp/old_roots
                  timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
                  mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
              fi

              delete_subvolume_recursively() {
                  IFS=$'\n'
                  for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                      delete_subvolume_recursively "/btrfs_tmp/$i"
                  done
                  btrfs subvolume delete "$1"
              }

              for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
                  delete_subvolume_recursively "$i"
              done

              btrfs subvolume create /btrfs_tmp/root
              umount /btrfs_tmp
            '';

          };
        };

      nixosModules.impermanence_home_script =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let

          cfg = config.custom.impermanence_home_script;
        in
        {

          options.custom.impermanence_home_script = {
            enable = lib.mkEnableOption "delete /home subvolume that are more than 30 days old";
          };

          config = lib.mkIf cfg.enable {

            boot.initrd.postResumeCommands = lib.mkAfter ''
              mkdir /btrfs_tmp
              mount /dev/disk/by-label/nixos /btrfs_tmp
              if [[ -e /btrfs_tmp/home ]]; then
                  mkdir -p /btrfs_tmp/old_homes
                  timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/home)" "+%Y-%m-%-d_%H:%M:%S")
                  mv /btrfs_tmp/home "/btrfs_tmp/old_homes/$timestamp"
              fi

              delete_subvolume_recursively() {
                  IFS=$'\n'
                  for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                      delete_subvolume_recursively "/btrfs_tmp/$i"
                  done
                  btrfs subvolume delete "$1"
              }

              for i in $(find /btrfs_tmp/old_homes/ -maxdepth 1 -mtime +30); do
                  delete_subvolume_recursively "$i"
              done

              btrfs subvolume create /btrfs_tmp/home
              umount /btrfs_tmp
            '';

          };
        };
    };
}
