{ lib, config, ... }:

let
  cfg = config.custom.networking.defaultSettings;

in
{

  options.custom.networking.defaultSettings = {
    enable = lib.mkEnableOption "Enable default network management";
  };

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = lib.mkDefault true;
  };
}
