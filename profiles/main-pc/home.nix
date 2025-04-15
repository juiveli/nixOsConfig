{
  lib,
  pkgs,
  config,
  ...
}:
with lib;

let
  sshfsRestart = pkgs.writeShellScriptBin "sshfs-restart" ''
    MOUNT_POINT="/media/rajalat"

    ${pkgs.coreutils}/bin/mkdir -p /media/rajalat

    if ! ${pkgs.util-linux}/bin/mountpoint -q "$MOUNT_POINT"; then
      echo "Not mounted, let's restart the mounting service..."
      ${pkgs.systemd}/bin/systemctl --user restart sshfs-rajalat.service; 
    else
      echo "SSHFS already mounted."
    fi
  '';

  sshfsSetup = pkgs.writeShellScriptBin "sshfs-setup" ''
    MOUNT_POINT="/media/rajalat"
    ${pkgs.coreutils}/bin/mkdir -p /media/rajalat

    ${pkgs.sshfs}/bin/sshfs juiveli@nyy.fi:/data /media/rajalat -o port=64542

    if ! ${pkgs.util-linux}/bin/mountpoint -q "$MOUNT_POINT"; then
      echo "SSHFS mount failed! Cleaning up..."
      ${pkgs.coreutils}/bin/rmdir "$MOUNT_POINT" 
    else
      echo "SSHFS successfully mounted."
    fi
  '';

in

{
  home.packages = [
    pkgs.sshfs
    pkgs.coreutils
    pkgs.util-linux
    pkgs.systemd
  ]; # Install SSHFS for the user

  systemd.user.services.sshfs-rajalat = {
    Unit = {
      Description = "Auto SSHFS Mount for /media/rajalat";
      After = [ "network.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${sshfsSetup}/bin/sshfs-setup";
      RemainAfterExit = true;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.services.sshfs-rajalat-restart = {
    Unit = {
      Description = "Force restart SSHFS service";
      After = [ "network.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${sshfsRestart}/bin/sshfs-restart";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.timers."sshfs-rajalat-restart" = {
    Install = {
      WantedBy = [ "timers.target" ];
    };
    Timer = {
      OnBootSec = "60s";
      OnUnitActiveSec = "60s";
      Unit = "sshfs-rajalat-restart.service";
    };
  };

}
