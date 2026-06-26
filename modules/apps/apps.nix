{ inputs, pkgs, ... }:

{
  environment.systemPackages =
    (with pkgs; [
      steam
      telegram-desktop
      qq
      libwacom
      hyfetch
      fastfetch
      gtop
      firefox
      google-chrome
      vscode
      hmcl
      lmstudio
      baidupcs-go
      libreoffice-fresh
      bubblewrap
    ])
    ++ [
      (pkgs.callPackage ../../packages/codex-upstream.nix {
        src = inputs.codex-upstream-bin.outPath;
      })
    ];
}
