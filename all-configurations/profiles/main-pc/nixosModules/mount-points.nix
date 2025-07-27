{
  lib,
  pkgs,
  config,
  ...
}:
with lib;

let
  cfg = config.services.mount-points;

  # Function to create mount points with optional bind mounts
  createMountPoints =
    {
      mountPoint,
      device,
      fsType,
      options,
      bindMounts ? [ ],
    }:
    {
      fileSystems = {
        # Main device mount
        "${mountPoint}" = {
          device = device;
          fsType = fsType;
          options = options;
        };
      }
      // builtins.listToAttrs (
        map (bind: {
          name = bind.path;
          value = {
            device = "${mountPoint}/${bind.relativePath}";
            fsType = "none";
            options = [ "bind" ] ++ (bind.options or [ ]);
            depends = [ "${mountPoint}" ];
          };
        }) bindMounts
      );
    };

in
{
  options.services.mount-points = {
    enable = mkEnableOption "mount-points";
  };

  config = mkIf cfg.enable {
    # Combine all fileSystems into a single attribute set
    fileSystems =
      (createMountPoints {
        mountPoint = "/mnt/toshiba";
        device = "/dev/disk/by-uuid/737a0019-ed50-4722-8cb2-1f1a2598bf7f";
        fsType = "ext4";
        options = [
          "users"
          "nofail"
        ];
        bindMounts = [
          {
            path = "/var/lib/containers/chia/chiaPlots/toshiba";
            relativePath = "chiaPlots";
            options = [ "ro" ];
          }
          {
            path = "/var/lib/containers/mmx/mmxPlots/toshiba";
            relativePath = "mmxPlots";
            options = [ "ro" ];
          }
          {
            path = "/media/toshiba";
            relativePath = ".";
          }
        ];
      }).fileSystems
      // (createMountPoints {
        mountPoint = "/mnt/seagate";
        device = "/dev/disk/by-uuid/079850d4-bc32-4405-9bf0-ac7abbfe9730";
        fsType = "ext4";
        options = [
          "users"
          "nofail"
        ];
        bindMounts = [
          {
            path = "/var/lib/containers/chia/chiaPlots/seagate";
            relativePath = "chiaPlots";
            options = [ "ro" ];
          }
          {
            path = "/var/lib/containers/mmx/mmxPlots/seagate";
            relativePath = "mmxPlots";
            options = [ "ro" ];
          }
          {
            path = "/media/seagate";
            relativePath = ".";
          }
        ];
      }).fileSystems
      // (createMountPoints {
        mountPoint = "/mnt/4tbHDD";
        device = "/dev/disk/by-uuid/90ec5797-5721-47a7-ac2d-bc709e2d19fc";
        fsType = "ext4";
        options = [
          "users"
          "nofail"
        ];
        bindMounts = [
          {
            path = "/var/lib/containers/chia/chiaPlots/4tbHDD";
            relativePath = "chiaPlots";
            options = [ "ro" ];
          }
          {
            path = "/var/lib/containers/mmx/mmxPlots/4tbHDD";
            relativePath = "mmxPlots";
            options = [ "ro" ];
          }
          {
            path = "/media/4tbHDD";
            relativePath = ".";
          }
        ];
      }).fileSystems
      // (createMountPoints {
        mountPoint = "/mnt/samsung4tb";
        device = "/dev/disk/by-uuid/3acc60b2-77c6-41e5-87e6-c96a99b3e53e";
        fsType = "xfs";
        options = [
          "users"
          "nofail"
        ];
        bindMounts = [
          {
            path = "/var/lib/containers/chia/chiaPlots/samsung4tb";
            relativePath = "chiaPlots";
            options = [ "ro" ];
          }
          {
            path = "/var/lib/containers/mmx/mmxPlots/samsung4tb";
            relativePath = "mmxPlots";
            options = [ "ro" ];
          }
          {
            path = "/media/samsung4tb";
            relativePath = ".";
          }
        ];
      }).fileSystems
      // (createMountPoints {
        mountPoint = "/mnt/myBook";
        device = "/dev/disk/by-uuid/F4BF-E7AD";
        fsType = "exfat";
        options = [
          "users"
          "nofail"
        ];
        bindMounts = [
          {
            path = "/var/lib/containers/chia/chiaPlots/myBook";
            relativePath = "chiaPlots";
            options = [ "ro" ];
          }
          {
            path = "/var/lib/containers/mmx/mmxPlots/myBook";
            relativePath = "mmxPlots";
            options = [ "ro" ];
          }
          {
            path = "/media/myBook";
            relativePath = ".";
          }
        ];
      }).fileSystems
      // (createMountPoints {
        mountPoint = "/mnt/noob";
        device = "/dev/disk/by-uuid/f9998937-9563-4f60-9d9b-989cd7156d44";
        fsType = "btrfs";
        options = [
          "users"
          "nofail"
        ];
        bindMounts = [
          {
            path = "/media/noob";
            relativePath = ".";
          }
        ];

      }).fileSystems;
  };
}
