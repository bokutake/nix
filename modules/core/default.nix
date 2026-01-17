{ pkgs, ... }:

{
  # Basic System Configuration
  time.timeZone = "Asia/Shanghai";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  # Nix Configuration
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://cache.nixos.org/"
    ];
  };
  
  # Garbage Collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  
  # Optimize storage
  nix.settings.auto-optimise-store = true;

  # User Configuration
  users.users.bokutake = {
    isNormalUser = true;
    description = "bokutake";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  # Enable sudo (enabled by default for wheel users, but ensuring security config)
  security.sudo.enable = true;

  # Shell Configuration
  programs.zsh.enable = true;

  environment.pathsToLink = [ "/share/icons" ];
  # Essential System Packages
  environment.systemPackages = with pkgs; [
    tree
    vim
    wget
    git
    htop
    unzip
  ];
}
