{ pkgs, ... }:

{
  systemd.services.sync-github-authorized-keys-bokutake = {
    description = "Sync bokutake authorized_keys from GitHub";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      set -eu

      tmpfile="$(mktemp)"
      trap 'rm -f "$tmpfile"' EXIT

      ${pkgs.curl}/bin/curl \
        --fail \
        --silent \
        --show-error \
        --location \
        https://github.com/bokutake.keys \
        > "$tmpfile"

      if [ ! -s "$tmpfile" ]; then
        echo "Downloaded GitHub key set is empty; keeping existing authorized_keys." >&2
        exit 1
      fi

      ${pkgs.coreutils}/bin/install -d -m 0700 -o bokutake -g users /home/bokutake/.ssh
      ${pkgs.coreutils}/bin/install -m 0600 -o bokutake -g users "$tmpfile" /home/bokutake/.ssh/authorized_keys
    '';
  };

  systemd.timers.sync-github-authorized-keys-bokutake = {
    description = "Refresh bokutake authorized_keys from GitHub";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "12h";
      Persistent = true;
    };
  };
}
