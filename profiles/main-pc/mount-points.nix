{ lib, pkgs, config, ... }:
with lib;
let
  # Shorter name to access final settings a
  # user of hello.nix module HAS ACTUALLY SET.
  # cfg is a typical convention.
  cfg = config.services.mount-points;
in {
  options.services.mount-points = { enable = mkEnableOption "mount-points"; };
  config = mkIf cfg.enable {
    fileSystems."/mnt/toshiba" = {
      device = "/dev/disk/by-uuid/737a0019-ed50-4722-8cb2-1f1a2598bf7f";
      fsType = "ext4";
      options =
        [ # If you don't have this options attribute, it'll default to "defaults"
          # boot options for fstab. Search up fstab mount options you can use
          "users" # Allows any user to mount and unmount
          "nofail" # Prevent system from failing if this drive doesn't mount
        ];
    };
    fileSystems."/mnt/noob" = {
      device = "/dev/disk/by-uuid/f9998937-9563-4f60-9d9b-989cd7156d44";
      fsType = "btrfs";
      label = "Johanneksen";
      options =
        [ # If you don't have this options attribute, it'll default to "defaults"
          # boot options for fstab. Search up fstab mount options you can use
          "users" # Allows any user to mount and unmount
          "nofail" # Prevent system from failing if this drive doesn't mount
        ];
    };
    fileSystems."/mnt/seagate" = {
      device = "/dev/disk/by-uuid/079850d4-bc32-4405-9bf0-ac7abbfe9730";
      fsType = "ext4";
      options =
        [ # If you don't have this options attribute, it'll default to "defaults"
          # boot options for fstab. Search up fstab mount options you can use
          "users" # Allows any user to mount and unmount
          "nofail" # Prevent system from failing if this drive doesn't mount
        ];
    };
    fileSystems."/mnt/4tbHDD" = {
      device = "/dev/disk/by-uuid/90ec5797-5721-47a7-ac2d-bc709e2d19fc";
      fsType = "ext4";
      options =
        [ # If you don't have this options attribute, it'll default to "defaults"
          # boot options for fstab. Search up fstab mount options you can use
          "users" # Allows any user to mount and unmount
          "nofail" # Prevent system from failing if this drive doesn't mount
        ];
    };
    fileSystems."/mnt/samsung4tb" = {
      device = "/dev/disk/by-uuid/3acc60b2-77c6-41e5-87e6-c96a99b3e53e";
      fsType = "xfs";
      options =
        [ # If you don't have this options attribute, it'll default to "defaults"
          # boot options for fstab. Search up fstab mount options you can use
          "users" # Allows any user to mount and unmount
          "nofail" # Prevent system from failing if this drive doesn't mount
        ];
    };
    fileSystems."/mnt/myBook" = {
      device = "/dev/disk/by-uuid/F4BF-E7AD";
      fsType = "exfat";
      options =
        [ # If you don't have this options attribute, it'll default to "defaults"
          # boot options for fstab. Search up fstab mount options you can use
          "users" # Allows any user to mount and unmount
          "nofail" # Prevent system from failing if this drive doesn't mount
        ];
    };
    ####################
    # Bind mounts
    # Mount /var/lib/containers/chia/chiaPlots/toshiba on /mnt/toshiba/chiaPlots
    # Accessing /var/lib/containers/chia/chiaPlots/toshiba will actually access /mnt/toshiba/chiaPlots...
    fileSystems."/var/lib/containers/chia/chiaPlots/toshiba" = {
      depends = [
        # The mounts above have to be mounted in this given order
        "/mnt/toshiba"
      ];
      device = "/mnt/toshiba/chiaPlots";
      fsType = "none";
      options = [
        "bind"
        "ro" # The filesystem hierarchy will be read-only when accessed from /mnt/toshiba/chiaPlots
        "nofail"
      ];
    };
    fileSystems."/var/lib/containers/mmx/mmxPlots/toshiba" = {
      depends = [ "/mnt/toshiba" ];
      device = "/mnt/toshiba/mmxPlots";
      fsType = "none";
      options = [ "bind" "ro" "nofail" ];
    };
    fileSystems."/var/lib/containers/chia/chiaPlots/seagate" = {
      depends = [ "/mnt/seagate" ];
      device = "/mnt/seagate/chiaPlots";
      fsType = "none";
      options = [ "bind" "ro" "nofail" ];
    };
    fileSystems."/var/lib/containers/mmx/mmxPlots/seagate" = {
      depends = [ "/mnt/seagate" ];
      device = "/mnt/seagate/mmxPlots";
      fsType = "none";
      options = [ "bind" "ro" "nofail" ];
    };
    fileSystems."/var/lib/containers/chia/chiaPlots/4tbHDD" = {
      depends = [ "/mnt/4tbHDD" ];
      device = "/mnt/4tbHDD/chiaPlots";
      fsType = "none";
      options = [ "bind" "ro" "nofail" ];
    };
    fileSystems."/var/lib/containers/mmx/mmxPlots/4tbHDD" = {
      depends = [ "/mnt/4tbHDD" ];
      device = "/mnt/4tbHDD/mmxPlots";
      fsType = "none";
      options = [ "bind" "ro" "nofail" ];
    };
    fileSystems."/var/lib/containers/chia/chiaPlots/samsung4tb" = {
      depends = [ "/mnt/samsung4tb" ];
      device = "/mnt/samsung4tb/chiaPlots";
      fsType = "none";
      options = [ "bind" "ro" "nofail" ];
    };
    fileSystems."/var/lib/containers/mmx/mmxPlots/samsung4tb" = {
      depends = [ "/mnt/samsung4tb" ];
      device = "/mnt/samsung4tb/mmxPlots";
      fsType = "none";
      options = [ "bind" "ro" "nofail" ];
    };
    fileSystems."/var/lib/containers/chia/chiaPlots/myBook" = {
      depends = [ "/mnt/myBook" ];
      device = "/mnt/myBook/chiaPlots";
      fsType = "none";
      options = [ "bind" "ro" "nofail" ];
    };
    fileSystems."/var/lib/containers/mmx/mmxPlots/myBook" = {
      depends = [ "/mnt/myBook" ];
      device = "/mnt/myBook/mmxPlots";
      fsType = "none";
      options = [ "bind" "ro" "nofail" ];
    };
  };
}
