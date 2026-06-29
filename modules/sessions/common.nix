{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    source-han-sans
    source-han-serif
    sarasa-gothic
    wqy_microhei
    wqy_zenhei
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
