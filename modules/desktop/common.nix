{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    nerd-fonts.jetbrains-mono
    jetbrains-mono
    material-symbols
    font-awesome
    nerd-fonts.fira-code
  ];

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      fcitx5-gtk
      fcitx5-lua
      libsForQt5.fcitx5-qt
      qt6Packages.fcitx5-configtool
      qt6Packages.fcitx5-chinese-addons
    ];
  };
}

