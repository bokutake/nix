{ pkgs, ... }:

{
  hardware.graphics.enable32Bit = true;

  programs.steam = {
    enable = true;
  };

  programs.gamemode.enable = true;

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  environment.systemPackages = with pkgs; [
    lutris
    mangohud
    protonup-qt
    vulkan-tools
    winetricks
  ];
}
