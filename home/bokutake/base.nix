{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";

  home.sessionVariables = {
    GTK_MODULES = "";
    QT_QPA_PLATFORMTHEME = "gtk3";
    QT_STYLE_OVERRIDE = "adwaita-dark";
  };

  home.file = {
    ".config/starship.toml" = {
      source = ../../dotfiles/dot_config/starship.toml;
      force = true;
    };

    ".config/fcitx5/config" = {
      source = ../../dotfiles/dot_config/fcitx5/config;
      force = true;
    };

    ".config/fontconfig/fonts.conf".text = ''
      <?xml version="1.0" encoding="utf-8"?>
      <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
      <fontconfig>
        <include ignore_missing="yes">/etc/fonts/fonts.conf</include>
        <include ignore_missing="yes">${config.xdg.configHome}/fontconfig/conf.d</include>
      </fontconfig>
    '';

    ".local/share/backgrounds/wallpaper.png" = {
      source = ../../assets/wallpaper.png;
      force = true;
    };

    ".local/share/backgrounds/bokutake.jpg" = {
      source = ../../assets/bokutake.jpg;
      force = true;
    };
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [
        "Noto Sans"
        "Noto Sans CJK SC"
        "Source Han Sans SC"
        "Sarasa Gothic SC"
        "WenQuanYi Micro Hei"
        "WenQuanYi Zen Hei"
      ];
      serif = [
        "Noto Serif"
        "Noto Serif CJK SC"
        "Source Han Serif SC"
      ];
      monospace = [
        "Sarasa Mono SC"
        "JetBrainsMono Nerd Font"
        "JetBrains Mono"
      ];
      emoji = [
        "Noto Color Emoji"
        "Noto Emoji"
      ];
    };
  };

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };
    envExtra = ''
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    '';
    initContent = ''
      eval "$(${pkgs.pay-respects}/bin/pay-respects zsh --alias)"
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    settings.user.name = "bokutake";
    settings.user.email = "i@html.moe";
    signing = {
      key = "4AA36D3E48DACF7059BB6C774AA091B0BB0B59D2";
      signByDefault = true;
    };
  };

  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };

  home.packages = with pkgs; [
    deploy-rs
    notion-app-enhanced
    terraform
    yubikey-manager
  ];
}
