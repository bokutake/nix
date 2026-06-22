{ lib, ... }:

{
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.timeout = 3;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    autoGenerateKeys.enable = true;
    autoEnrollKeys.enable = true;
    autoEnrollKeys.autoReboot = true;
    autoEnrollKeys.includeMicrosoftKeys = false;
    autoEnrollKeys.allowBrickingMyMachine = true;
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  boot.initrd.kernelModules = [ "i915" ];
  boot.initrd.availableKernelModules = [ "tpm_tis" ];

  # The security scan warns if this drifts from the current Btrfs swapfile mapping.
  boot.resumeDevice = "/dev/mapper/pool-root";
  boot.kernelParams = [
    "resume_offset=2187232"
  ];
}
