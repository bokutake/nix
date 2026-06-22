{ pkgs, ... }:

{
  # ---------------------------------------------------------
  # Storage & Swap Optimization
  # ---------------------------------------------------------
  # Btrfs compression is handled in disko-config (compress=zstd)
  
  # 10GB Physical Swap (for S4/Hibernation)
  hardware.btrfs-swap = {
    enable = true;
    size = 10;
  };

  # zram for memory extension (4GB limit)
  zramSwap = {
    enable = true;
    memoryMax = 4096 * 1024 * 1024; # 4GB in bytes
  };

  nix.settings.auto-optimise-store = true;

  # Enable trim for SSD
  services.fstrim.enable = true;

  # Hibernation resume config
  boot.resumeDevice = "/dev/mapper/pool-root";
  boot.kernelParams = [ "resume_offset=1225141" ]; 
}
