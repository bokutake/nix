{ pkgs, ... }:

{
  users.users.bokutake = {
    isNormalUser = true;
    description = "bokutake";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  security.sudo.enable = true;
  programs.zsh.enable = true;
}
