{ pkgs, ... }:

{
  imports = [ ./tablet-sw.nix ];
  
  # ---------------------------------------------------------
  # Libwacom Tablet Definition for Chromebook Stylus
  # ---------------------------------------------------------
  services.libinput.enable = true;

  environment.etc."libwacom/google-zork.tablet".text = ''
    [Device]
    Name=GDIX0000:00 27C6:0ED4 Stylus
    ModelName=Lenovo ThinkPad C13 Yoga Chromebook (Morphius)
    DeviceMatch=i2c|27c6|0ed4
    Class=ISDV4
    Width=12
    Height=7
    IntegratedIn=Display;System
    Styli=@generic-no-eraser

    [Features]
    Stylus=true
    Touch=false
    Buttons=0
  '';
  environment.variables.LIBWACOM_DATA_DIR = "/etc/libwacom";

  # fix libinput size detection for the stylus
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="event*", ATTRS{capabilities/ev}=="1b", ATTRS{name}=="*Stylus*", \
      ENV{ID_INPUT_WIDTH_MM}="293", \
      ENV{ID_INPUT_HEIGHT_MM}="167", \
      ENV{ID_INPUT_STYLUS}="1", \
      ENV{ID_INPUT_TABLET}="1", \
      ENV{LIBINPUT_ATTR_GHOST_TIME}="50", \
      ENV{LIBINPUT_ATTR_GHOST_RANGE}="0.05"

    ACTION=="add|change", KERNEL=="event*", ATTRS{name}=="*GDIX0000*", ATTRS{capabilities/ev}=="1", ENV{LIBINPUT_IGNORE_DEVICE}="1"
    ACTION=="add|change", KERNEL=="event*", ATTRS{name}=="*GDIX0000*", ATTRS{capabilities/ev}=="9", ENV{LIBINPUT_IGNORE_DEVICE}="1"
  '';

# backup
#    ACTION=="add|change", KERNEL=="event*", ATTRS{capabilities/ev}=="b", ATTRS{name}=="GDIX0000:00 27C6:0ED4", ATTRS{name}!="*Stylus*", \
#      ENV{LIBINPUT_ATTR_TOUCH_ARBITRATION}="0", \
#      ENV{LIBINPUT_DEVICE_GROUP}="touch_exclusive_group"

  # ---------------------------------------------------------
  # Keyd Configuration for Chromebook Layout
  # ---------------------------------------------------------
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        main = {
          # Search -> CapsLock
          leftmeta = "capslock";
          
          # Right Alt -> Super (Left Meta)
          rightalt = "leftmeta";

          # Lock -> Delete
          sleep = "delete"; # Common mapping for lock key

          # Top Row Mapping (Media -> F-keys)
          # Assumes kernel maps them to standard media keys
          back = "f1";
          forward = "f2";
          refresh = "f3";
          zoom = "f4";
          scale = "f5";
          brightnessdown = "f6";
          brightnessup = "f7";
          mute = "f8";
          volumedown = "f9";
          volumeup = "f10";
        };

        # Super (via Right Alt) + Top Row -> Original Function
        meta = {
          back = "back";
          forward = "forward";
          refresh = "refresh";
          zoom = "zoom";
          scale = "scale";
          brightnessdown = "brightnessdown";
          brightnessup = "brightnessup";
          mute = "mute";
          volumedown = "volumedown";
          volumeup = "volumeup";
        };
      };
    };
  };
}
