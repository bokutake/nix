{ pkgs, ... }:

{
  # Hyprland Configuration
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  
  # XDG Portal (Required for screen sharing etc.)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    nerd-fonts.jetbrains-mono
    jetbrains-mono
    material-symbols 
    font-awesome
    nerd-fonts.fira-code
  ];

  # Input Method (Fcitx5)
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      fcitx5-gtk
      fcitx5-lua
      libsForQt5.fcitx5-qt
      qt6Packages.fcitx5-configtool
      qt6Packages.fcitx5-chinese-addons
    ];
  };

  # Polkit Agent (Required for GUI auth)
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

  # Required Packages
  environment.systemPackages = with pkgs; [
    swww
    brightnessctl
    playerctl
    swaybg        # Wallpaper utility
    kitty         # Terminal emulator
    wl-clipboard  # Clipboard manager
    wofi          # Application launcher
    swaylock      # Screen locker
    papirus-icon-theme
    matugen
    ddcutil
    jq
    wf-recorder
    # Addons
    polkit_gnome  # Polkit agent
    hyprshot
    grim          # Screenshot
    slurp         # Screenshot selection
    networkmanagerapplet # NM applet
  ];
}
