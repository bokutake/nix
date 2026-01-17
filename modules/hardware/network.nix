{ pkgs, ... }:

{
  # Enable NetworkManager
  networking.networkmanager.enable = true;

  # ModemManager Configuration
  networking.modemmanager.enable = true;
  
  # Restart ModemManager after suspend/hibernate to fix connectivity issues
  systemd.services.ModemManager = {
    wantedBy = [ "multi-user.target" ];
    after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    serviceConfig = {
      # Reduce shutdown timeout to avoid hanging
      TimeoutStopSec = "5s";
    };
  };

  # Hook to restart ModemManager on resume
  powerManagement.resumeCommands = ''
    ${pkgs.systemd}/bin/systemctl restart ModemManager.service
  '';

  environment.systemPackages = with pkgs; [
    modem-manager-gui
    libqmi
    libmbim
  ];
}
