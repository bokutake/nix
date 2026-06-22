{ config, lib, pkgs, ... }:

{
  services.upower.enable = true;

  environment.systemPackages = with pkgs; [
    s-tui
    powertop
    acpi
  ];
}
