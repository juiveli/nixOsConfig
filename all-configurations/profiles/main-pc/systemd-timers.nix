{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let

  cfg = config.services.systemd-timers;
in
{
  options.services.systemd-timers = {
    enable = mkEnableOption "systemd-timers";
  };

  config = mkIf cfg.enable {

    # For these to work, you need to add your own script to /var/lib/dnsIpUpdater/checkAndUpdateDns.sh
    systemd.timers."ip-updater-to-dns-always-when-run" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "Mon,Fri 9:00";
        Persistent = true;
        Unit = "ip-updater-to-dns-always-when-run.service";
      };
    };
    systemd.timers."ip-updater-to-dns-only-if-needed" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "60s";
        OnUnitActiveSec = "5m";
        Unit = "ip-updater-to-dns-only-if-needed.service";
      };
    };
    systemd.services."ip-updater-to-dns-always-when-run" = {
      path = with pkgs; [
        bash
        curl
      ];
      script = ''
        bash /var/lib/dnsIpUpdater/checkAndUpdateDns.sh "yes"
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
    systemd.services."ip-updater-to-dns-only-if-needed" = {
      path = with pkgs; [
        bash
        curl
      ];
      script = ''
        bash /var/lib/dnsIpUpdater/checkAndUpdateDns.sh
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };

  };
}
