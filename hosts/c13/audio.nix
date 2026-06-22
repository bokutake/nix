{ pkgs, ... }:

{
  # ---------------------------------------------------------
  # Hardware: Audio (Chromebook Special)
  # ---------------------------------------------------------
  boot.kernelParams = [
    "snd_pci_acp3x.dmic_detect=1" 
    "snd_soc_dmic.enable=1"
    "snd_acp3x_rn.dmic_detect=1"
  ];

  environment.systemPackages = with pkgs; [
    alsa-ucm-conf
    alsa-utils
    pavucontrol
    pulsemixer
    wireplumber
  ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true; 
  };


  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  boot.kernelModules = [ "snd_pci_acp3x" "snd_soc_alc5682" "snd_soc_alc5682_i2c" ];
}
