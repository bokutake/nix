{ pkgs, ... }:

{
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;
  services.gnome.gnome-browser-connector.enable = true;

  environment.systemPackages = with pkgs; [
    gnome-browser-connector
    gnomeExtensions.appindicator
    gnomeExtensions.caffeine
    gnomeExtensions.gjs-osk
  ];
}
