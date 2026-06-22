{ pkgs, ... }:

{
  environment.pathsToLink = [ "/share/icons" ];

  environment.systemPackages = with pkgs; [
    tree
    vim
    wget
    git
    htop
    unzip
  ];
}
