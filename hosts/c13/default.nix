{ inputs, config, pkgs, lib, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.lanzaboote.nixosModules.lanzaboote
    
    ./disko-config.nix

    ./hardware-configuration.nix
    
    ../../modules/presets/gnome-workstation.nix
    #../../modules/sessions/hyprland-optional.nix
    
    # Hardware modules
    # So laggy on battery... use ppd instead
    # ../../modules/hardware/tlp.nix
    ../../modules/hardware/btrfs-swap.nix

    # Local split configuration
    ./boot.nix
    ./storage.nix
    ./desktop.nix
    ./audio.nix
    ./input.nix
    ./cpu.nix
    ./gpu.nix
  ];

  networking.hostName = "bokutake-morpheus";

  #desktop.hyprland = {
  #  enable = true;
  #  enableHome = false;
  #};

  # QoL: Firmware updates
  services.fwupd.enable = true;
  
  # QoL: Sensor support (iio) for tablet mode
  hardware.sensor.iio.enable = true;

  services.baidupcs-rust.enable = true;

  system.stateVersion = "25.11";
}
