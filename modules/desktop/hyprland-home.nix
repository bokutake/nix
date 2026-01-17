{ pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ../../dotfiles/dot_config/hypr/hyprland.conf;
    
    settings = {
      exec-once = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP SSH_AUTH_SOCK"
        "swww-daemon --format xrgb && sleep 1 && swww img ${../../assets/wallpaper.png}" 
      ];
    };
  };

  home.file.".config/hypr/hyprshot.conf" = {
    source = ../../dotfiles/dot_config/hypr/hyprshot.conf;
    force = true;
  };
}
