{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let

  cfg = config.services.custom-folders;
in
{
  options.services.custom-folders = {
    enable = mkEnableOption "custom-folders";
    username = mkOption {
      type = types.str;
      default = "joonas";
    };
    usergroup = mkOption {
      type = types.str;
      default = "users";
    };
  };

  config = mkIf cfg.enable {

    systemd.tmpfiles.settings = {

      "custom_scritps_folders" = {
        "/var/lib/dnsIpUpdater" = {
          d = {
            group = cfg.usergroup;
            mode = "0755";
            user = cfg.username;
          };
        };
      };
    };
  };
}
