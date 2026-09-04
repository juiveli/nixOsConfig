{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvm1n1"; # <-- Change to your actual disk (e.g. /dev/sda, /dev/nvme0n1)
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "boot";
              name = "ESP";
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                  "umask=0077"
                ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-L"
                  "nixos"
                  "-f"
                ];
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "subvol=root"
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "subvol=home"
                      "compress=zstd"
                      "noatime"
                    ];
                    neededForBoot = true;
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "subvol=nix"
                      "compress=zstd"
                      "noatime"
                    ];
                    neededForBoot = true;
                  };
                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = [
                      "subvol=persist"
                      "compress=zstd"
                      "noatime"
                    ];
                    neededForBoot = true;
                  };
                  "/persist/swap" = {
                    mountpoint = "/persist/swap";
                    mountOptions = [
                      "subvol=swap"
                      "noatime"
                      "nodatacow"
                    ];
                    # Size should be >= your RAM for hibernation to fit the
                    # full memory image.
                    swap.swapfile.size = "32G"; # adjust to ~= your RAM, useful for hibernation
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  # Forces /persist to mount during initrd (stage 1 boot) before system services launch
  fileSystems."/persist".neededForBoot = true;
}
