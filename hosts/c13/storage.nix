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

  # Prefer zram over disk swap to reduce SSD writes under memory pressure.
  zramSwap = {
    enable = true;
    memoryMax = 8 * 1024 * 1024 * 1024; # 8 GiB in bytes
    priority = 1000;
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
  };

  nix.settings.auto-optimise-store = true;

  # Enable trim for SSD
  services.fstrim.enable = true;

  # Hibernation resume config
  boot.resumeDevice = "/dev/mapper/pool-root";
  boot.kernelParams = [ "resume_offset=1225141" ]; 
}
