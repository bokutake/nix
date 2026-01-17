{ pkgs, ... }: {
  boot = {
    plymouth = {
      enable = true;
      theme = "spinnerv2";
      themePackages = [
        (pkgs.stdenv.mkDerivation {
          pname = "plymouth-spinnerv2-theme";
          version = "1.0";
          src = pkgs.fetchFromGitHub {
            owner = "Andy3153";
            repo = "plymouth-spinnerv2-theme";
            rev = "master";
            sha256 = "sha256-3aLUSXqBFbnKRmpV7+NfDJ6CcSGQwbZjOh6oJqS8Ma0=";
          };
          installPhase = ''
            mkdir -p $out/share/plymouth/themes/spinnerv2
            cp -r * $out/share/plymouth/themes/spinnerv2/
            find $out/share/plymouth/themes/ -name \*.plymouth -exec sed -i "s@\/usr\/@$out\/@" {} \;
          '';
        })
      ];
    };

    consoleLogLevel = 3;
    initrd.verbose = false;
    initrd.kernelModules = [ "i915" ];
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
  };
}