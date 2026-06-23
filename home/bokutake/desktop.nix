{ config, lib, osConfig, pkgs, ... }:

let
  clashPartyEnabled =
    (osConfig.desktop.clash.frontend or null) == "party"
    || (osConfig.desktop.clash-party.enable or false);
in
{
  home.activation.removeLegacyClashDesktopEntries = lib.mkIf clashPartyEnabled (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Clash Party is the selected frontend; remove stale per-user Clash Verge launchers
      # so a second frontend does not race TUN/core state during login.
      rm -f "${config.home.homeDirectory}/.config/autostart/Clash Verge.desktop"
      rm -f "${config.home.homeDirectory}/.local/share/applications/Clash Verge.desktop"
      rm -f "${config.home.homeDirectory}/.local/share/applications/clash-verge.desktop"
    ''
  );

  programs.clash-party = lib.mkIf clashPartyEnabled {
    startup = {
      silent = true;
      autoCheckUpdate = false;
    };

    systemProxy = {
      enable = true;
      mode = "manual";
    };

    features = {
      controlDns = true;
      controlSniff = true;
      tcpConcurrent = true;

      tun.enable = true;
    };

    ports = {
      socks.enable = false;
      http.enable = false;
    };

    dns = {
      fakeIpFilterMode = "blacklist";
    };

    app = {
      useWindowFrame = false;
      proxyInTray = true;
      showCurrentProxyInTray = false;
      enableTrafficLogger = true;
      trayProxyGroupStyle = "default";
      disableTrayIconColor = false;
      customTrayIcon = "";
      maxLogDays = 7;
      maxLogFileSize = 10;
      disableAppLog = false;
      proxyCols = "auto";
      connectionDirection = "asc";
      connectionOrderBy = "time";
      autoQuitWithoutCore = false;
      autoQuitWithoutCoreDelay = 60;
      autoQuitWithoutCoreMode = "core";
      proxyDisplayMode = "simple";
      proxyDisplayOrder = "default";
      testProfileOnStart = true;
      useNameserverPolicy = false;
      nameserverPolicy = { };
      floatingWindowCompatMode = true;
      disableHardwareAcceleration = false;
      hideConnectionCardWave = false;
      siderOrder = [
        "sysproxy"
        "tun"
        "profile"
        "proxy"
        "rule"
        "resource"
        "override"
        "connection"
        "mihomo"
        "dns"
        "sniff"
        "log"
        "substore"
        "network"
        "usage"
      ];
      siderWidth = 250;
      triggerMainWindowBehavior = "show";
    };

    mihomo = {
      profile = {
        storeSelected = true;
        storeFakeIp = true;
      };

      tun = {
        stack = "mixed";
        autoRoute = true;
        autoRedirect = true;
        autoDetectInterface = true;
        dnsHijack = [ "any:53" ];
        mtu = 1500;
        device = "Mihomo";
        strictRoute = true;
      };

      dns = {
        ipv6 = false;
        defaultNameserver = [ "tls://223.5.5.5" ];
        nameserver = [
          "https://doh.pub/dns-query"
          "https://dns.alidns.com/dns-query"
        ];
        proxyServerNameserver = [
          "https://doh.pub/dns-query"
          "https://dns.alidns.com/dns-query"
        ];
        fallbackFilter = {
          geoip = true;
          geoipCode = "CN";
          ipcidr = [ "240.0.0.0/4" "0.0.0.0/32" ];
          domain = [ "+.google.com" "+.facebook.com" "+.youtube.com" ];
        };
      };

      sniffer = {
        parsePureIp = true;
        forceDnsMapping = true;
        skipDomain = [ "+.push.apple.com" ];
        skipDstAddress = [
          "91.105.192.0/23"
          "91.108.4.0/22"
          "91.108.8.0/21"
          "91.108.16.0/21"
          "91.108.56.0/22"
          "95.161.64.0/20"
          "149.154.160.0/20"
          "185.76.151.0/24"
          "2001:67c:4e8::/48"
          "2001:b28:f23c::/47"
          "2001:b28:f23f::/48"
          "2a0a:f280:203::/48"
        ];
      };
    };
  };

  home.file.".config/hyfetch.json".text = builtins.toJSON {
    preset = "rainbow";
    mode = "rgb";
    auto_detect_light_dark = true;
    light_dark = "dark";
    lightness = 0.65;
    color_align = { mode = "horizontal"; };
    backend = "fastfetch";
    args = null;
    distro = null;
    pride_month_disable = false;
    custom_ascii_path = null;
  };

  dconf.enable = true;
  dconf.settings = let
    gnomeEnabled = osConfig.services.desktopManager.gnome.enable or false;
    wp = "file:///home/bokutake/.local/share/backgrounds/wallpaper.png";
  in {
    "org/gnome/desktop/background" = {
      picture-uri = wp;
      picture-uri-dark = wp;
      picture-options = "zoom";
    };
    "org/gnome/desktop/screensaver" = {
      picture-uri = wp;
    };
  } // lib.optionalAttrs gnomeEnabled {
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
    };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "caffeine@patapon.info"
        "gjsosk@vishram1123.com"
      ];
    };
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    gtk4.theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "adwaita-dark";
  };
}
