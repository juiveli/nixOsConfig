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

    users.groups.router = { };

    users.users.router = {
      isNormalUser = true;
      home = "/home/router";
      description = "router";
      extraGroups = [
        "wheel"
      ];
      packages = [ ];

      group = "router";
    };

  };
}
