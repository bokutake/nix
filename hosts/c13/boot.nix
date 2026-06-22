{ pkgs, lib, ... }:

{
  # ---------------------------------------------------------
  # Boot & Security (Lanzaboote)
  # ---------------------------------------------------------
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
  boot.initrd.availableKernelModules = [ "tpm_tis" ];
  # Increase SWIOTLB size to avoid OOM
  boot.kernelParams = [ "swiotlb=65536" ];
  # Patch for C13 yoga chromebook
  systemd.services.inazuma-security-scan.script = lib.mkForce ''
    STATUS_DIR="/run/inazuma-security"
    mkdir -p "$STATUS_DIR"

    # --- TPM2 Override Section ---
    # C13 Coreboot TPM2 is unusable, so we override it to suppress alerts
    echo "ok" > "$STATUS_DIR/tpm2_state"
    > "$STATUS_DIR/bad_luks_devs"

    if [ -f /swap/swapfile ]; then
      CURRENT=$(${pkgs.btrfs-progs}/bin/btrfs inspect-internal map-swapfile -r /swap/swapfile 2>/dev/null || echo "0")
      CONFIGURED=$(cat /proc/cmdline | grep -oP 'resume_offset=\K\d+' || echo "0")
      if [ "$CURRENT" != "0" ] && [ "$CURRENT" != "$CONFIGURED" ]; then
        echo "bad" > "$STATUS_DIR/offset_state"
        echo "$CURRENT" > "$STATUS_DIR/current_offset"
        echo "$CONFIGURED" > "$STATUS_DIR/config_offset"
      else
        echo "ok" > "$STATUS_DIR/offset_state"
      fi
    fi
  '';
}
