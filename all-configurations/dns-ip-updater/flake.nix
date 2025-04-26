{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs =
    { nixpkgs, sops-nix, ... }:
    {
      homeManagerModules.quadlet =
        {
          config,
          lib,
          pkgs,
          ...
        }:

        let
          cfg = config.services.dns-ip-updater;

          dnsIpUpdaterScript = pkgs.writeShellScriptBin "dns-ip-updater" ''
              #!/bin/bash

              USERNAME=$(cat ${config.sops.secrets."dy-fi/username".path})
              PASSWORD=$(cat ${config.sops.secrets."dy-fi/password".path})

              SERVER_HOSTNAME=(
                "generic.tunk.org"
                "test.generic.tunk.org"
                "test2.generic.tunk.org"
                "test.juiveli.fi"
                "juiveli.fi"
              )

              URL_BASE="https://www.dy.fi/nic/update?hostname="
              IP_FILE=''${HOME}/.dnsIpUpdater/current_ip.txt
              CURRENT_IP=$(curl -s https://ipv4.icanhazip.com)


              # Ensure directory and file exist
              mkdir -p "$(dirname "$IP_FILE")"
              touch "$IP_FILE"

              OLD_IP=$(cat "$IP_FILE")

              # Compare the old IP with the current one
              if [[ "$CURRENT_IP" != "$OLD_IP" || "$1" == "yes" ]]; then
                echo "IP has changed from $OLD_IP to $CURRENT_IP. Updating..."
                echo "$CURRENT_IP" > "$IP_FILE"

                # Convert the space-separated string into a Bash array
                for URL in ''${SERVER_HOSTNAME[@]}; do
                  curl -u ''$USERNAME:$PASSWORD ''${URL_BASE}''${URL}
              done

            fi
          '';

        in
        {

          options.services.dns-ip-updater.dy-fi = {
            enable = lib.mkEnableOption "Dns Ip updater";
          };

          config = {

            sops.secrets = {
              "dy-fi/username" = {
                sopsFile = ./dy-fi.yaml;
                format = "yaml";

              };

              "dy-fi/password" = {
                sopsFile = ./dy-fi.yaml;
                format = "yaml";

              };

            };

            systemd.user.services."ip-updater-to-dns-always-when-run" = {
              Unit = {
                Description = "Update DNS always when run - periodic updater";
              };
              Service = {
                ExecStart = "${dnsIpUpdaterScript}/bin/dns-ip-updater yes";
                Type = "oneshot";
              };
            };

            systemd.user.timers."ip-updater-to-dns-always-when-run" = {
              Unit = {
                Description = "Timer for ip-updater-to-dns-always-when-run service";
              };
              Timer = {
                OnCalendar = "Mon,Fri 9:00";
                Persistent = true;
                Unit = "ip-updater-to-dns-always-when-run.service";
              };
              Install = {
                WantedBy = [ "timers.target" ];
              };
            };

            systemd.user.services."ip-updater-to-dns-only-if-needed" = {
              Unit = {
                Description = "Update DNS only if needed - frequent updater";
              };
              Service = {
                ExecStart = "${dnsIpUpdaterScript}/bin/dns-ip-updater";
                Type = "oneshot";
              };
            };

            systemd.user.timers."ip-updater-to-dns-only-if-needed" = {
              Unit = {
                Description = "Timer for ip-updater-to-dns-only-if-needed service";
              };
              Timer = {
                OnBootSec = "60s";
                OnUnitActiveSec = "5m";
                Unit = "ip-updater-to-dns-only-if-needed.service";
              };
              Install = {
                WantedBy = [ "timers.target" ];
              };
            };

          };
        };
    };
}
