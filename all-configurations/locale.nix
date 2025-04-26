# This file set the default locale settings which are overridable

{ config, lib, ... }:

let
  cfg = config.custom.defaultLocale;

in
{

  options.custom.defaultLocale = {
    enable = lib.mkEnableOption "Get default locale settings. Settings from here is overridable";
  };

  config =
    lib.mkIf cfg.enable

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
      };
}
