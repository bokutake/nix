{ config, lib, pkgs, ... }:

let
  cfg = config.desktop.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
      };
    };

    environment.systemPackages = with pkgs; [
      hypridle
      quickshell
      swww
      brightnessctl
      playerctl
      swaybg
      kitty
      wl-clipboard
      wofi
      swaylock
      papirus-icon-theme
      matugen
      ddcutil
      jq
      wf-recorder
      polkit_gnome
      hyprshot
      grim
      slurp
      networkmanagerapplet
    ];
  };
}
