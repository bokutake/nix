{ config, lib, pkgs, ... }:

let
  cfg = config.desktop.clash-party;
  clashParty = pkgs.callPackage ../../packages/clash-party.nix { };
in
{
  options.desktop.clash-party = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install Clash Party and provision its privileged sidecar cores.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ clashParty ];

    desktop.proxy = {
      enable = true;
      mixedPort = lib.mkDefault 7897;
      dnsPort = lib.mkDefault 11453;
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/clash-party 0755 root root -"
      "d /var/lib/clash-party/sidecar 0755 root root -"
    ];

    system.activationScripts.clashPartySidecars.text = ''
      install_core() {
        local src="$1"
        local dst="$2"
        ${pkgs.coreutils}/bin/install -D -m 4755 -o root -g root "$src" "$dst"
      }

      install_core \
        "${clashParty}/lib/clash-party/resources/nix-sidecar-store/mihomo.bin.real" \
        "/var/lib/clash-party/sidecar/mihomo"
      install_core \
        "${clashParty}/lib/clash-party/resources/nix-sidecar-store/mihomo-alpha.bin.real" \
        "/var/lib/clash-party/sidecar/mihomo-alpha"
      install_core \
        "${clashParty}/lib/clash-party/resources/nix-sidecar-store/mihomo-smart.bin.real" \
        "/var/lib/clash-party/sidecar/mihomo-smart"

      install_core \
        "${clashParty}/lib/clash-party/resources/nix-sidecar-store/mihomo.bin.real" \
        "/var/lib/clash-party/sidecar/mihomo.bin"
      install_core \
        "${clashParty}/lib/clash-party/resources/nix-sidecar-store/mihomo-alpha.bin.real" \
        "/var/lib/clash-party/sidecar/mihomo-alpha.bin"
      install_core \
        "${clashParty}/lib/clash-party/resources/nix-sidecar-store/mihomo-smart.bin.real" \
        "/var/lib/clash-party/sidecar/mihomo-smart.bin"
    '';
  };
}
