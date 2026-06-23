{ ... }:

{
  imports = [
    ./workstation-base.nix
    ../sessions/hyprland-optional.nix
    ../sessions/hyprland.nix
  ];

  desktop.hyprland = {
    enable = true;
    enableHome = true;
  };
}
