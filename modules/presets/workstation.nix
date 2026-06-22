{ ... }:

{
  imports = [
    ./workstation-base.nix
    ../desktop/hyprland-optional.nix
    ../desktop/hyprland.nix
  ];

  desktop.hyprland = {
    enable = true;
    enableHome = true;
  };
}
