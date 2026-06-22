{ config, lib, pkgs, ... }:

{
  # ---------------------------------------------------------
  # Throttled Configuration (T480s Lab Verified Specs)
  # ---------------------------------------------------------
  services.throttled.enable = true;
  services.throttled.extraConfig = ''
  [GENERAL]
  Enabled: True
  Sysfs_Power_Path: /sys/class/power_supply/AC*/online

  [AC]
  Update_Rate_s: 5
  PL1_Tdp_W: 25
  PL1_Duration_s: 28
  PL2_Tdp_W: 44
  PL2_Duration_S: 0.002
  Trip_Temp_C: 90

  [BATTERY]
  Update_Rate_s: 30
  PL1_Tdp_W: 15
  PL1_Duration_s: 28
  PL2_Tdp_W: 22
  PL2_Duration_S: 0.002
  Trip_Temp_C: 85

  [UNDERVOLT.AC]
  CORE: -90
  CACHE: -90
  GPU: -45
  UNCORE: -90
  ANALOGIO: 0

  [UNDERVOLT.BATTERY]
  CORE: -90
  CACHE: -90
  GPU: -45
  UNCORE: -90
  ANALOGIO: 0

  [ICCMAX.AC]
  CORE: 128
  CACHE: 128  '';

  # Undervolt tool for manual verification
  environment.systemPackages = with pkgs; [
    undervolt
  ];
}
