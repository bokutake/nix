{ pkgs, ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "yes";
    };
  };

  # PC/SC Smart Card Daemon
  services.pcscd.enable = true;

  # TPM2 Support
  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true; # Optional: Expose TPM2 via PKCS11
  security.tpm2.tctiEnvironment.enable = true; # User-space TCTI environment variables

  # Secure Boot
  environment.systemPackages = with pkgs; [
    sbctl
  ];

  systemd.services.inazuma-security-scan = {
    description = "Inazuma OS Security Health Check";
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ 
      util-linux
      gnugrep
      gawk
      coreutils
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      RuntimeDirectory = "inazuma-security";
      RuntimeDirectoryMode = "0755";
    };
    script = ''
      STATUS_DIR="/run/inazuma-security"
      
      LUKS_DEVICES=$(${pkgs.util-linux}/bin/lsblk -ln -o PATH,FSTYPE | grep crypto_LUKS | awk '{print $1}')
      echo "ok" > "$STATUS_DIR/tpm2_state"
      > "$STATUS_DIR/bad_luks_devs"
      for dev in $LUKS_DEVICES; do
        if ! ${pkgs.systemd}/bin/systemd-cryptenroll "$dev" 2>/dev/null | grep -q "tpm2"; then
          echo "bad" > "$STATUS_DIR/tpm2_state"
          echo "$dev" >> "$STATUS_DIR/bad_luks_devs"
        fi
      done

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
  };

  programs.zsh.interactiveShellInit = ''  

    if [ -e /sys/firmware/efi/efivars ]; then
      SB_STATUS=$(${pkgs.sbctl}/bin/sbctl status | grep -q "Secure Boot:.*Enabled" && echo "ok" || echo "bad")

      SCAN_DIR="/run/inazuma-security"
      TPM2_STATE=$(cat "$SCAN_DIR/tpm2_state" 2>/dev/null || echo "ok")
      OFFSET_STATE=$(cat "$SCAN_DIR/offset_state" 2>/dev/null || echo "ok")

      if [[ "$SB_STATUS" == "bad" || "$SB_VERIFY" == "bad" || "$TPM2_STATE" == "bad" || "$OFFSET_STATE" == "bad" ]]; then
        print -P "%B%F{magenta}⚡ Inazuma OS Security & Integrity Alert:%f%b"

        if [[ "$SB_STATUS" == "bad" ]]; then
          print -P "  %F{red}✗%f Secure Boot is NOT active!"
          print -P "    %F{blue}➜%f Run: %F{cyan}sudo sbctl status%f"
        fi

        if [[ "$TPM2_STATE" == "bad" ]]; then
          for dev in $(cat "$SCAN_DIR/bad_luks_devs"); do
            print -P "  %F{yellow}⚠%f LUKS Device $dev has no TPM2 token!"
            print -P "    %F{blue}➜%f Run: %F{cyan}sudo systemd-cryptenroll --tpm2-device=auto $dev%f"
            print -P "    %F{blue}➜%f Use %F{cyan}--tpm2-with-pin=true%f for maximum security."
          done
        fi

        if [[ "$OFFSET_STATE" == "bad" ]]; then
          CUR_OFF=$(cat "$SCAN_DIR/current_offset")
          CON_OFF=$(cat "$SCAN_DIR/config_offset")
          print -P "  %F{red}✗%f Hibernation Offset Mismatch!"
          print -P "    %F{blue}➜%f Current: %F{yellow}$CUR_OFF%f | Config: %F{red}$CON_OFF%f"
          print -P "    %F{blue}➜%f Update %F{cyan}boot.kernelParams%f with: %F{magenta}\"resume_offset=$CUR_OFF\"%f"
          print -P "  And reboot."
        fi
        echo ""
      fi
    fi
  '';
}
