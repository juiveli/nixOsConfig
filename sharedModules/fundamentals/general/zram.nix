{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.zram;

in
{

  options.custom.zram = {
    enable = lib.mkEnableOption "Enable zram and assumes impermanence was used to create swap file";
  };

  config = lib.mkIf cfg.enable {

    zramSwap = {
      enable = true;
      algorithm = "zstd"; # "lzo", "lz4", or "zstd"
      priority = 100;
      memoryPercent = 50; # % of RAM available as compressed swap
    };

    # If you used disko to partition, this is fine
    swapDevices = [
      {
        device = "/persist/swap/swapfile";
        priority = 1; # Lower priority -> used only when zram is full
      }
    ];

  };
}
