{ config, lib, ... }:

let
  cfg = config.desktop.proxy;
  proxyHost = cfg.host;
  dnsEndpoint =
    if cfg.dns != null then
      cfg.dns
    else if cfg.dnsPort != null then
      "${proxyHost}:${toString cfg.dnsPort}"
    else
      null;
  daemonProxyUrl =
    if cfg.daemonProxy != null then
      cfg.daemonProxy
    else if cfg.mixedPort != null then
      "socks5h://${proxyHost}:${toString cfg.mixedPort}"
    else
      null;
in
{
  options.desktop.proxy = {
    enable = lib.mkEnableOption "system integration for a local proxy backend";

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Local loopback host used by the selected proxy backend.";
    };

    mixedPort = lib.mkOption {
      type = lib.types.nullOr lib.types.port;
      default = null;
      description = "Mixed inbound port exposed by the local proxy backend.";
    };

    dnsPort = lib.mkOption {
      type = lib.types.nullOr lib.types.port;
      default = null;
      description = "Canonical local Mihomo DNS port consumed by systemd-resolved and GUI-managed config.";
    };

    dns = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "DNS endpoint exposed by the local proxy backend.";
    };

    daemonProxy = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Proxy URL exported to nix-daemon.";
    };

    fallbackDns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "223.5.5.5" "1.1.1.1" "2400:3200::1" "2606:4700:4700::1111" ];
      description = "Fallback DNS servers used by systemd-resolved.";
    };

    enableRouting = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable kernel forwarding settings commonly required by TUN-based proxy backends.";
    };

    endpoints = lib.mkOption {
      readOnly = true;
      description = "Canonical exported local proxy endpoints for downstream modules such as Home Manager.";
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };

          host = lib.mkOption {
            type = lib.types.str;
            default = "127.0.0.1";
          };

          mixedPort = lib.mkOption {
            type = lib.types.nullOr lib.types.port;
            default = null;
          };

          dnsPort = lib.mkOption {
            type = lib.types.nullOr lib.types.port;
            default = null;
          };

          dnsEndpoint = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
          };

          daemonProxyUrl = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
          };
        };
      };
      default = {
        enable = cfg.enable;
        host = proxyHost;
        inherit dnsEndpoint daemonProxyUrl;
        mixedPort = cfg.mixedPort;
        dnsPort = cfg.dnsPort;
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable (
      lib.mkMerge [
        (lib.mkIf (dnsEndpoint != null) {
          networking.networkmanager.dns = "systemd-resolved";
          networking.resolvconf.enable = false;

          services.resolved = {
            enable = true;
            settings.Resolve = {
              DNSOverTLS = false;
              DNSSEC = false;
              DNS = [ dnsEndpoint ];
              FallbackDNS = cfg.fallbackDns;
              Domains = [ "~." ];
            };
          };
        })

        (lib.mkIf cfg.enableRouting {
          boot.kernel.sysctl = {
            "net.ipv4.ip_forward" = 1;
            "net.ipv4.conf.all.forwarding" = 1;
            "net.ipv4.conf.all.rp_filter" = 0;
            "net.ipv4.conf.default.rp_filter" = 0;
          };
        })

        (lib.mkIf (daemonProxyUrl != null) {
          systemd.services.nix-daemon.environment = {
            http_proxy = daemonProxyUrl;
            https_proxy = daemonProxyUrl;
            all_proxy = daemonProxyUrl;
            HTTP_PROXY = daemonProxyUrl;
            HTTPS_PROXY = daemonProxyUrl;
            ALL_PROXY = daemonProxyUrl;
            NO_PROXY = "127.0.0.1,localhost,.local";
            no_proxy = "127.0.0.1,localhost,.local";
          };
        })
      ]
    ))
  ];
}
