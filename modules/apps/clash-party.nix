{ config, inputs, lib, pkgs, ... }:

let
  cfg = config.desktop.clash-party;
  clashParty =
    inputs.clash-party-packaging.packages.${pkgs.stdenv.hostPlatform.system}.clash-party;
in
{
  imports = [ inputs.clash-party-packaging.nixosModules.default ];

  options.desktop.clash-party = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install Clash Party and provision its privileged sidecar cores.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.clash-party = {
      enable = true;
      package = clashParty;
    };

    desktop.proxy = {
      enable = true;
      mixedPort = lib.mkDefault 7897;
      dnsPort = lib.mkDefault 11453;
    };
  };
}
