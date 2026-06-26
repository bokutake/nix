{ config, lib, ... }:

let
  cfg = config.services.baidupcs-rust;
  proxyUrl = config.desktop.proxy.endpoints.daemonProxyUrl or null;
  proxyEnvironment = {
    http_proxy = proxyUrl;
    https_proxy = proxyUrl;
    all_proxy = proxyUrl;
    HTTP_PROXY = proxyUrl;
    HTTPS_PROXY = proxyUrl;
    ALL_PROXY = proxyUrl;
    NO_PROXY = "127.0.0.1,localhost,.local";
    no_proxy = "127.0.0.1,localhost,.local";
  };
in
{
  options.services.baidupcs-rust = {
    enable = lib.mkEnableOption "BaiduPCS-Rust OCI service";

    backend = lib.mkOption {
      type = lib.types.enum [ "podman" "docker" ];
      default = "podman";
      description = "OCI container backend used to run BaiduPCS-Rust.";
    };

    image = lib.mkOption {
      type = lib.types.str;
      default = "docker.io/komorebicarry/baidupcs-rust:2.1.1@sha256:e74d183a4a81622bceffd237f6ae6bc1e614e3a0c339f3b17625ea46853268e3";
      description = "BaiduPCS-Rust container image.";
    };

    address = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Host address to bind the BaiduPCS-Rust web UI to.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 18888;
      description = "Host port for the BaiduPCS-Rust web UI.";
    };

    stateDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/baidupcs-rust";
      description = "Persistent host directory for BaiduPCS-Rust data.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      virtualisation.oci-containers = {
        backend = cfg.backend;
        containers.baidu-netdisk-rust = {
          image = cfg.image;
          ports = [ "${cfg.address}:${toString cfg.port}:18888" ];
          volumes = [
            "${cfg.stateDir}/config:/app/config"
            "${cfg.stateDir}/downloads:/app/downloads"
            "${cfg.stateDir}/data:/app/data"
            "${cfg.stateDir}/logs:/app/logs"
            "${cfg.stateDir}/wal:/app/wal"
          ];
          environment = {
            RUST_LOG = "info";
            RUST_BACKTRACE = "1";
          };
          extraOptions = [
            "--cpus=2"
            "--memory=2g"
            "--health-cmd=curl -f http://localhost:18888/health"
            "--health-interval=30s"
            "--health-timeout=5s"
            "--health-retries=3"
            "--health-start-period=30s"
          ];
        };
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.stateDir} 0750 root root - -"
        "d ${cfg.stateDir}/config 0750 root root - -"
        "d ${cfg.stateDir}/downloads 0750 root root - -"
        "d ${cfg.stateDir}/data 0750 root root - -"
        "d ${cfg.stateDir}/logs 0750 root root - -"
        "d ${cfg.stateDir}/wal 0750 root root - -"
      ];
    }

    (lib.mkIf (cfg.backend == "podman" && proxyUrl != null) {
      systemd.services.podman-baidu-netdisk-rust.environment = proxyEnvironment;
    })

    (lib.mkIf (cfg.backend == "docker" && proxyUrl != null) {
      systemd.services.docker-baidu-netdisk-rust.environment = proxyEnvironment;
    })

    (lib.mkIf (cfg.backend == "podman") {
      virtualisation.podman.enable = true;
    })

    (lib.mkIf (cfg.backend == "docker") {
      virtualisation.docker.enable = true;
    })
  ]);
}
