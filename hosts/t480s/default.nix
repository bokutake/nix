{ inputs, config, pkgs, lib, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480s
    inputs.lanzaboote.nixosModules.lanzaboote
    
    ./disko-config.nix # Import Disko configuration

    # Import common workstation preset
    ../../modules/presets/hyprland-workstation.nix

    # Enable Greetd (Login Manager)
    ../../modules/sessions/greetd.nix

    # Hardware Support Modules
    ../../modules/hardware/btrfs-swap.nix
    ../../modules/hardware/tlp.nix
    
    # T480s Specifics
    ./boot.nix
    ./storage.nix
    ./power-optimization.nix # T480s specific power tuning
    
    # Include hardware-configuration.nix if available
    ./hardware-configuration.nix
  ];

  # Networking Hostname
  networking.hostName = "bokutake-t480s";
  system.stateVersion = "25.11";
}
