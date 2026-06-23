{ config, lib, ... }:

let
  cfg = config.desktop.clash;
in
{
  options.desktop.clash = {
    frontend = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "party" "verge" ]);
      default = null;
      description = "Select the Clash desktop frontend to enable on this host.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.frontend == "party") {
      desktop.clash-party.enable = lib.mkDefault true;
    })

    (lib.mkIf (cfg.frontend == "verge") {
      desktop.clash-verge.enable = lib.mkDefault true;
    })

    {
      assertions = [
        {
          assertion =
            let
              enabledFrontends =
                builtins.length
                  (builtins.filter (x: x) [
                    config.desktop.clash-party.enable
                    config.desktop.clash-verge.enable
                  ]);
            in
            enabledFrontends <= 1;
          message = "Enable at most one Clash desktop frontend at a time.";
        }
      ];
    }
  ];
}
