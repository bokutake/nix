{ pkgs, lib, ... }:

{
  services.power-profiles-daemon.enable = lib.mkForce false;

  powerManagement.enable = true;

  i18n.inputMethod = lib.mkForce {
    enable = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [
      rime
      libpinyin
    ];
  };

  environment.systemPackages = with pkgs; [
    libwacom
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="input", ATTRS{name}=="GDIX0000:00 27C6:0ED4", ENV{LIBINPUT_ATTR_TOUCH_ARBITRATION}="0"
  '';

  systemd.services.force-user-avatar = {
    description = "Force set user avatar for AccountsService";
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /var/lib/AccountsService/users
      echo -e "[User]\nIcon=/home/bokutake/.local/share/backgrounds/bokutake.jpg\nSystemAccount=false" > /var/lib/AccountsService/users/bokutake
      chown root:root /var/lib/AccountsService/users/bokutake
      chmod 644 /var/lib/AccountsService/users/bokutake
    '';
  };
}
