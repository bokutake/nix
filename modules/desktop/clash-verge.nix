{ ... }:

let
  nixDaemonProxy = "socks5h://127.0.0.1:7897";
in
{
  programs.clash-verge = {
    enable = true;
    serviceMode = true;
    tunMode = true;
    autoStart = true;
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv4.conf.all.rp_filter" = 0;
    "net.ipv4.conf.default.rp_filter" = 0;
  };

  systemd.services.nix-daemon.environment = {
    http_proxy = nixDaemonProxy;
    https_proxy = nixDaemonProxy;
    all_proxy = nixDaemonProxy;
    HTTP_PROXY = nixDaemonProxy;
    HTTPS_PROXY = nixDaemonProxy;
    ALL_PROXY = nixDaemonProxy;
    NO_PROXY = "127.0.0.1,localhost,.local";
    no_proxy = "127.0.0.1,localhost,.local";
  };
}
