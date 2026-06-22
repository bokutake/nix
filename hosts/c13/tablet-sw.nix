{ config, pkgs, ... }:

let
  tablet-monitor-c = pkgs.writeText "tablet-monitor.c" ''
    #include <stdio.h>
    #include <stdlib.h>
    #include <unistd.h>
    #include <fcntl.h>
    #include <string.h>
    #include <linux/input.h>

    void set_keyd(int state) {
        if (state == 1) {
            printf("[Tablet] Active\n");
            system("systemctl stop keyd");
        } else {
            printf("[Laptop] Active\n");
            system("systemctl start keyd");
        }
        fflush(stdout);
    }

    int main() {
        setvbuf(stdout, NULL, _IONBF, 0);

        char name[256];
        char dev_path[64];
        int fd = -1;

        for (int i = 0; i < 32; i++) {
            snprintf(dev_path, sizeof(dev_path), "/dev/input/event%d", i);
            fd = open(dev_path, O_RDONLY);
            if (fd < 0) continue;

            if (ioctl(fd, EVIOCGNAME(sizeof(name)), name) >= 0) {
                if (strcmp(name, "Tablet Mode Switch") == 0) {
                    break; 
                }
            }
            close(fd);
            fd = -1;
        }

        if (fd == -1) return 1;

        unsigned long sw_states[1];
        if (ioctl(fd, EVIOCGSW(sizeof(sw_states)), sw_states) != -1) {
            set_keyd((sw_states[0] >> SW_TABLET_MODE) & 1);
        }

        struct input_event ev;
        while (read(fd, &ev, sizeof(struct input_event)) > 0) {
            if (ev.type == EV_SW && ev.code == SW_TABLET_MODE) {
                set_keyd(ev.value);
            }
        }
        return 0;
    }
  '';

  tablet-bin = pkgs.runCommand "tablet-monitor-bin" {} ''
    mkdir -p $out/bin
    ${pkgs.stdenv.cc}/bin/cc ${tablet-monitor-c} -o $out/bin/morpheus-tablet-monitor
  '';
in
{
  systemd.services.tablet-mode-switchd = {
    description = "Morpheus Tablet Mode Switch Daemon";
    wantedBy = [ "multi-user.target" ];
    after = [ "keyd.service" ];
    serviceConfig = {
      ExecStart = "${tablet-bin}/bin/morpheus-tablet-monitor";
      Restart = "always";
      DeviceAllow = [ "char-input r" ];
      ProtectSystem = "full";
      CapabilityBoundingSet = [ "CAP_SYS_ADMIN" ];
    };
  };
}
