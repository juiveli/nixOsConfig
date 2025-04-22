{
  config,
  lib,
  pkgs,
  ...
}:
{

  users.users.joonas = {
    isNormalUser = true;
    description = "joonas";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = [ ];
  };

}
