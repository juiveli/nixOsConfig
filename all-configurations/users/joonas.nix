{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.users.joonas;

in
{

  options.users.joonas = {
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
