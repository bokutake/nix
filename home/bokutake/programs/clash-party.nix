{ inputs, lib, osConfig, pkgs, ... }:

let
  clashPartyEnabled =
    (osConfig.desktop.clash.frontend or null) == "party"
    || (osConfig.desktop.clash-party.enable or false);
  proxyEndpoints = osConfig.desktop.proxy.endpoints or { };
  linkedMixedPort =
    if (proxyEndpoints.enable or false) && (proxyEndpoints.mixedPort or null) != null then
      proxyEndpoints.mixedPort
    else
      null;
  linkedDnsListen =
    if (proxyEndpoints.enable or false) && (proxyEndpoints.dnsPort or null) != null then
      "0.0.0.0:${toString proxyEndpoints.dnsPort}"
    else
      null;
  clashPartyPackage =
    inputs.clash-party-packaging.packages.${pkgs.stdenv.hostPlatform.system}.clash-party;
in
{
  imports = [ inputs.clash-party-packaging.homeManagerModules.default ];

  config = lib.mkIf clashPartyEnabled {
    programs.clash-party.enable = lib.mkDefault true;
    programs.clash-party.package = lib.mkDefault clashPartyPackage;

    programs.clash-party.links = {
      mixedPort = lib.mkDefault linkedMixedPort;
      dnsListen = lib.mkDefault linkedDnsListen;
      systemProxy = {
        enable = lib.mkDefault true;
        mode = lib.mkDefault "manual";
      };
    };
  };
}
