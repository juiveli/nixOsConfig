{ lib, config, ... }:

let
  cfg = config.custom.boot.loader.defaultSettings;

in
{

  options.custom.boot.loader.defaultSettings = {
    enable = lib.mkEnableOption "Enable default bootloader";
  };

  config = lib.mkIf cfg.enable {

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
}
