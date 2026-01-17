{ inputs, config, pkgs, lib, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480s
    inputs.lanzaboote.nixosModules.lanzaboote
    
    ./disko-config.nix # Import Disko configuration

    # Import common workstation preset
    ../../modules/presets/workstation.nix
    
    # T480s Specifics
    ./power-optimization.nix # T480s specific power tuning
    
    # Include hardware-configuration.nix if available
    ./hardware-configuration.nix
  ];

  # Networking Hostname
  networking.hostName = "bokutake-t480s";

  # Boot configuration
  # UKI + Secure Boot (Lanzaboote)

  # Force disable systemd-boot to avoid conflicts with Lanzaboote
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.grub.enable = false;
  
  # Limit the number of generations to keep in the bootloader/EFI
  boot.loader.systemd-boot.configurationLimit = 5;
  
  # Hide menu by default (press Space/Shift to show) for a cleaner boot
  boot.loader.timeout = 3;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    autoGenerateKeys.enable = true;
    autoEnrollKeys.enable = true;
    autoEnrollKeys.autoReboot = true;
    # Disable Microsoft keys
    autoEnrollKeys.includeMicrosoftKeys = false;
    autoEnrollKeys.allowBrickingMyMachine = true;
  };

  boot.loader.efi.canTouchEfiVariables = true;
  
  # Enable systemd in initrd for TPM2 unlocking support
  boot.initrd.systemd.enable = true;
  # Ensure TPM kernel modules are loaded in initrd
  # T480s typically uses tpm_tis
  boot.initrd.availableKernelModules = [ "tpm_tis" ];

  # Hibernate Configuration
  # Note: You must calculate the resume_offset manually after swapfile creation
  # Run: btrfs inspect-internal map-swapfile -r /swap/swapfile
  boot.resumeDevice = "/dev/mapper/pool-root";
  boot.kernelParams = [ 
    "resume_offset=2187232" # TODO: Replace 0 with actual offset
  ];

  # Swapfile creation via systemd service (simplified approach)
  systemd.services.create-swapfile = {
    serviceConfig.Type = "oneshot";
    wantedBy = [ "multi-user.target" ];
    script = ''
      if [ ! -f /swap/swapfile ]; then
        # Create empty file first
        truncate -s 0 /swap/swapfile
        
        # Disable COW immediately on empty file (Critical for Btrfs)
        ${pkgs.e2fsprogs}/bin/chattr +C /swap/swapfile
        
        # Allocate size
        ${pkgs.coreutils}/bin/truncate -s 32G /swap/swapfile
        
        chmod 600 /swap/swapfile
        ${pkgs.util-linux}/bin/mkswap /swap/swapfile
      fi
    '';
  };
  
  swapDevices = [ { 
    device = "/swap/swapfile"; 
    size = 32 * 1024; # 32GB
  } ];

  system.stateVersion = "25.11";
}
