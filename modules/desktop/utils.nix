{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    hyfetch
    fastfetch
    gtop
    wayvnc
  ];

  home-manager.users.bokutake = {
    home = {
      stateVersion = "25.11"; 
      
      file.".config/hyfetch.json".text = builtins.toJSON {
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
    };
  };
}