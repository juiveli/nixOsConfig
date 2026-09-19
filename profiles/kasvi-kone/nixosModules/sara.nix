{
  config,
  lib,
  pkgs,
  ...
}:


  {
    users.groups.sara = { };

    users.users.sara = {
      isNormalUser = true;
      home = "/home/sara";
      description = "sara";
      extraGroups = [
        "networkmanager"
        "wheel"
        "service-control"
      ];
      packages = [ ];

      group = "sara";
    };

  }
