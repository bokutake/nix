{ lib, osConfig, pkgs, ... }:

{
  home.file.".config/hyfetch.json".text = builtins.toJSON {
    preset = "rainbow";
    mode = "rgb";
    auto_detect_light_dark = true;
    light_dark = "dark";
    lightness = 0.65;
    color_align = { mode = "horizontal"; };
    backend = "fastfetch";
    args = null;
    distro = null;
    pride_month_disable = false;
    custom_ascii_path = null;
  };

  dconf.enable = true;
  dconf.settings = let
    gnomeEnabled = osConfig.services.desktopManager.gnome.enable or false;
    wp = "file:///home/bokutake/.local/share/backgrounds/wallpaper.png";
  in {
    "org/gnome/desktop/background" = {
      picture-uri = wp;
      picture-uri-dark = wp;
      picture-options = "zoom";
    };
    "org/gnome/desktop/screensaver" = {
      picture-uri = wp;
    };
  } // lib.optionalAttrs gnomeEnabled {
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
    };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "caffeine@patapon.info"
        "gjsosk@vishram1123.com"
      ];
    };
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    gtk4.theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "adwaita-dark";
  };
}
