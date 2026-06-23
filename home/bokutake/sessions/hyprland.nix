{ lib, osConfig, inputs, ... }:

let
  hyprlandEnabled = osConfig.desktop.hyprland.enableHome or false;
in
{
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];

  config = lib.mkIf hyprlandEnabled {
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "hyprlang";
      extraConfig = builtins.readFile ../../../dotfiles/dot_config/hypr/hyprland.conf;

      settings = {
        exec-once = [
          "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP SSH_AUTH_SOCK"
          "awww-daemon --format xrgb && sleep 1 && awww img ${../../../assets/wallpaper.png}"
        ];
      };
    };

    home.file.".config/hypr/hyprshot.conf" = {
      source = ../../../dotfiles/dot_config/hypr/hyprshot.conf;
      force = true;
    };

    programs.caelestia = {
      enable = true;
      systemd = {
        enable = true;
        target = "graphical-session.target";
        environment = [ ];
      };
      cli.enable = true;
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "caelestia shell lock lock";
          before_sleep_cmd = "loginctl lock-session && sleep 2.5";
          after_sleep_cmd = ''
            hyprctl dispatch dpms on
          '';
        };
        listener = [ ];
      };
    };
  };
}
