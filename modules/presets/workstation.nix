{ config, pkgs, ... }:

{
  imports = [
    # Core Configuration
    ../core/default.nix

    # Desktop Environment (Hyprland, Greetd, Plymouth)
    ../desktop/hyprland.nix
    ../desktop/greetd.nix
    ../desktop/plymouth.nix
    ../desktop/utils.nix
    ../desktop/home-manager.nix

    # Hardware Support (Generic)
    ../hardware/power.nix
    ../hardware/network.nix
    ../hardware/audio.nix
    ../hardware/bluetooth.nix

    # Security
    ../security/default.nix
  ];
}