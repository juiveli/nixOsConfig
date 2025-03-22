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
      "containers_folder" = {
        "/var/lib/containers" = {

          d = {
            group = cfg.usergroup;
            mode = "0755";
            user = cfg.username;
          };
        };
      };

      "chia_folders" = {
        "/var/lib/containers/chia" = {
          d = {
            group = cfg.usergroup;
            mode = "0755";
            user = cfg.username;
          };
        };

        "/var/lib/containers/chia/chiaPlots" = {
          d = {
            group = cfg.usergroup;
            mode = "0755";
            user = cfg.username;
          };
        };

        "/var/lib/containers/chia/.chia" = {
          d = {
            group = cfg.usergroup;
            mode = "0755";
            user = cfg.username;
          };
        };
      };

      "mmx_folders" = {
        "/var/lib/containers/mmx/data" = {
          d = {
            group = cfg.usergroup;
            mode = "0755";
            user = cfg.username;
          };
        };

        "/var/lib/containers/mmx/mmxPlots" = {
          d = {
            group = cfg.usergroup;
            mode = "0755";
            user = cfg.username;
          };
        };
      };

      "caddy_folders" = {

        "/var/lib/containers/caddy" = {
          d = {
            group = cfg.usergroup;
            mode = "0755";
            user = cfg.username;
          };
        };

        "/var/lib/containers/caddy/srv" = {
          d = {
            group = cfg.usergroup;
            mode = "0755";
            user = cfg.username;
          };
        };

        "/var/lib/containers/caddy/caddy_data" = {
          d = {
            group = cfg.usergroup;
            mode = "0755";
            user = cfg.username;
          };
        };

        "/var/lib/containers/caddy/caddy_config" = {
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
