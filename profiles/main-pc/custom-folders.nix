{ lib, pkgs, config, ... }:
with lib;
let

  cfg = config.services.custom-folders;
in {
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
      "chia_folders" = {
        "/var/lib/chia" = {
          d = {
            group = cfg.usergroup;
            mode = "0755";
            user = cfg.username;
          };
        };

        "/var/lib/chia/chiaPlots" = {
          d = {
            group = cfg.usergroup;
            mode = "0755";
            user = cfg.username;
          };
        };

        "/var/lib/chia/.chia" = {
          d = {
            group = cfg.usergroup;
            mode = "0755";
            user = cfg.username;
          };
        };
      };

      "mmx_folders" = {
        "/var/lib/mmx/data" = {
          d = {
            group = cfg.usergroup;
            mode = "0755";
            user = cfg.username;
          };
        };

        "/var/lib/mmx/mmxPlots" = {
          d = {
            group = cfg.usergroup;
            mode = "0755";
            user = cfg.username;
          };
        };
      };

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
