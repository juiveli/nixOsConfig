# This file set the default locale settings which are overridable.
# There is no enable or disable option here, as these are just defaults added
# Overwrite them in other config if needed

{ lib, ... }:

{
  time.timeZone = lib.mkDefault "Europe/Helsinki";

  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = lib.mkDefault "fi_FI.UTF-8";
    LC_IDENTIFICATION = lib.mkDefault "fi_FI.UTF-8";
    LC_MEASUREMENT = lib.mkDefault "fi_FI.UTF-8";
    LC_MONETARY = lib.mkDefault "fi_FI.UTF-8";
    LC_NAME = lib.mkDefault "fi_FI.UTF-8";
    LC_NUMERIC = lib.mkDefault "fi_FI.UTF-8";
    LC_PAPER = lib.mkDefault "fi_FI.UTF-8";
    LC_TELEPHONE = lib.mkDefault "fi_FI.UTF-8";
    LC_TIME = lib.mkDefault "fi_FI.UTF-8";
  };
}
