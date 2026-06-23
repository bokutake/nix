{ config, lib, ... }:

let
  cfg = config.desktop.clash-verge;
in
{
  options.desktop.clash-verge = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Clash Verge and its shared proxy frontend defaults.";
    };
  };

  config = lib.mkIf cfg.enable {
    desktop.proxy = {
      enable = true;
      mixedPort = lib.mkDefault 7897;
      dnsPort = lib.mkDefault 11453;
    };

    programs.clash-verge = {
      enable = true;
      serviceMode = true;
      tunMode = true;
      autoStart = true;
    };
  };
}
