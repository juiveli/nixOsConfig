{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs =
    { nixpkgs, sops-nix, ... }:
    {
      nixosModules.quadlet =
        {
          config,
          lib,
          pkgs,
          ...
        }:

        let
          cfg = config.services.dns-ip-updater.dy-fi;

          # Creates <serviceName>-checked and <serviceName>-forced services and timers. For example. dns-ip-updater-forced.service
          serviceName = "dns-ip-updater";

          # creates var/lib/<stateDirectory>
          stateDirectory = serviceName;

          serviceUser = serviceName;
          serviceGroup = serviceName;

          dnsIpUpdaterScript = pkgs.writeShellScriptBin "${serviceName}" ''
              #!/bin/bash

              USERNAME=$(cat ${config.sops.secrets."dy-fi/username".path})
              PASSWORD=$(cat ${config.sops.secrets."dy-fi/password".path})

              SERVER_HOSTNAME=(
                "generic.tunk.org"
                "test.generic.tunk.org"
                "test2.generic.tunk.org"
                "test.juiveli.fi"
                "juiveli.fi"
                "static.juiveli.fi"
                "blog.juiveli.fi"
              )

              URL_BASE="https://www.dy.fi/nic/update?hostname="
              IP_FILE="''${STATE_DIRECTORY}/current_ip.txt"
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

          config = lib.mkIf cfg.enable {

            sops.secrets = {
              "dy-fi/username" = {
                sopsFile = ./dy-fi.yaml;
                format = "yaml";
                owner = serviceUser;

              };

              "dy-fi/password" = {
                sopsFile = ./dy-fi.yaml;
                format = "yaml";
                owner = serviceUser;

              };

            };

            users.groups.${serviceGroup} = { };
            users.users.${serviceUser} = {
              isSystemUser = true;
              description = "Used for ${serviceName} service";
              group = serviceGroup;

              extraGroups = [
              ];
              packages = [ ];
            };

            systemd.services."${serviceName}-forced" = {
              path = [ pkgs.curl ];
              description = "Forced updates for ${serviceName}";
              serviceConfig = {
                ExecStart = "${dnsIpUpdaterScript}/bin/${serviceName} yes";
                Type = "oneshot";
                User = serviceUser;
                Group = serviceGroup;
                StateDirectory = stateDirectory;
                StateDirectoryMode = "0750";
              };
            };

            systemd.timers."${serviceName}-forced" = {
              description = "Timer for forced updates of ${serviceName}";

              timerConfig = {
                OnCalendar = "Mon,Fri 9:00";
                Persistent = true;
                Unit = "${serviceName}-forced.service";
              };
              wantedBy = [ "timers.target" ];
            };

            systemd.services."${serviceName}-checked" = {
              path = [ pkgs.curl ];
              description = "Checked updates for ${serviceName}";
              serviceConfig = {
                ExecStart = "${dnsIpUpdaterScript}/bin/${serviceName}";
                Type = "oneshot";
                User = serviceUser;
                Group = serviceGroup;
                StateDirectory = stateDirectory;
                StateDirectoryMode = "0750";
              };
            };

            systemd.timers."${serviceName}-checked" = {
              description = "Timer for checked updates of ${serviceName}";
              timerConfig = {
                OnBootSec = "60s";
                OnUnitActiveSec = "5m";
                Unit = "${serviceName}-checked.service";
              };
              wantedBy = [ "timers.target" ];
            };
          };
        };
    };
}
