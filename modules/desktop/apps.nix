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
      lmstudio
      libreoffice-fresh
    ])
    ++ [
      (pkgs.callPackage ../../packages/codex-upstream.nix {
        src = inputs.codex-upstream-bin.outPath;
      })
    ];
}
