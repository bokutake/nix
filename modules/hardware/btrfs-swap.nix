{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hardware.btrfs-swap;
in
{
  options.hardware.btrfs-swap = {
    enable = mkEnableOption "Btrfs swapfile creation";
    
    size = mkOption {
      type = types.int;
      default = 16;
      description = "Size of the swapfile in GB";
    };
    
    path = mkOption {
      type = types.str;
      default = "/swap/swapfile";
      description = "Path to the swapfile";
    };
  };

  config = mkIf cfg.enable {
    # Swapfile creation via systemd service
    systemd.services.create-swapfile = {
      serviceConfig.Type = "oneshot";
      wantedBy = [ "multi-user.target" ];
      script = ''
        if [ ! -f ${cfg.path} ]; then
          mkdir -p "$(dirname ${cfg.path})"

          # Create empty file first
          truncate -s 0 ${cfg.path}
          
          # Disable COW immediately on empty file (Critical for Btrfs)
          ${pkgs.e2fsprogs}/bin/chattr +C ${cfg.path}
          
          # Allocate size
          ${pkgs.coreutils}/bin/truncate -s ${toString cfg.size}G ${cfg.path}
          
          chmod 600 ${cfg.path}
          ${pkgs.util-linux}/bin/mkswap ${cfg.path}
        fi
      '';
    };
    
    swapDevices = [ { 
      device = cfg.path; 
      size = cfg.size * 1024;
      priority = 10;
    } ];
  };
}
