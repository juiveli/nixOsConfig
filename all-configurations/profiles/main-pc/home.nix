{
  lib,
  pkgs,
  config,
  ...
}:
with lib;

let
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

  systemd.user.services.sshfs-mounts = {
    Unit = {
      Description = "Auto SSHFS Mount for /media/rajalat";
      After = [ "network.target" ];
    };
    Service = {
      Type = "forking";
      ExecStart = "${sshfsSetup}/bin/sshfs-setup";
      RestartSec = "120";
      Restart = "always";

      # Perform additional cleanup AFTER SSHFS is fully unmounted
      ExecStopPost = "${pkgs.coreutils}/bin/rmdir /media/rajalat";

    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
