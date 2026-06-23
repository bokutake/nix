{ lib, config, ... }:

let
  cfg = config.desktop.hyprland;
in
{
  options.desktop.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland system integration";
    enableHome = lib.mkEnableOption "Enable Hyprland-specific Home Manager config";
  };
}
