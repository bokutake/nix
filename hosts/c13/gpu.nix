{ config, pkgs, ... }:

{
  boot.kernelParams = [
    "amdgpu.dcfeaturemask=0xA"
    "amdgpu.ppfeaturemask=0xffffffff"
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };
}
