{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.users.joonas;

in
{

  options.custom.users.joonas = {
    enable = lib.mkEnableOption "user Joonas";
  };

  config = lib.mkIf cfg.enable {

    users.users.joonas = {
      isNormalUser = true;
      description = "joonas";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      packages = [ ];
    };

  };
}
