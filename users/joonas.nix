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

    users.groups.joonas = { };

    users.users.joonas = {
      isNormalUser = true;
      home = "/home/joonas";
      description = "joonas";
      extraGroups = [
        "networkmanager"
        "wheel"
        "service-control"
      ];
      packages = [ ];

      group = "joonas";
    };

  };
}
