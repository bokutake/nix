{ pkgs, inputs, ... }:

{
  home-manager.users.bokutake = {
    home.stateVersion = "25.11"; 

    imports = [ 
      inputs.caelestia-shell.homeManagerModules.default
      ./hyprland-home.nix
    ];

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
      initContent= ''
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

    programs.gpg = {
      enable = true;
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentry.package = pkgs.pinentry-gnome3;
    };

    home.packages = with pkgs; [
      yubikey-manager
    ];

    programs.caelestia = {
      enable = true;
      systemd = {
        enable = true;
        target = "graphical-session.target";
        environment = [];
      };
    };

    gtk = {
      enable = true;
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "gtk3";
      style.name = "adwaita-dark";
    };
  };
}
