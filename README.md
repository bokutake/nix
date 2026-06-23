# bokutake/nix

Personal NixOS flake for two machines:

- `c13`: Lenovo ThinkPad C13 Yoga Chromebook running GNOME
- `t480s`: Lenovo ThinkPad T480s running Hyprland via `greetd`

This repository keeps system configuration, user Home Manager config, hardware-specific splits, and a small set of local package wrappers in one flake.

## Layout

```text
.
├── flake.nix
├── home/
│   └── bokutake/
├── hosts/
│   ├── c13/
│   └── t480s/
├── modules/
│   ├── apps/
│   ├── core/
│   ├── hardware/
│   ├── home/
│   ├── network/
│   ├── presets/
│   ├── security/
│   └── sessions/
└── packages/
```

## Structure

- `hosts/<name>/`: machine-specific assembly and overrides
- `home/bokutake/`: Home Manager configuration for the primary user
- `home/bokutake/programs/`: user-space program modules such as Clash Party
- `home/bokutake/sessions/`: user-space session modules such as Hyprland
- `modules/apps/`: desktop applications, gaming, and Clash frontend adapters
- `modules/core/`: locale, Java runtime defaults, Nix settings, users, base packages
- `modules/hardware/`: reusable hardware support modules
- `modules/home/`: Home Manager bridge modules
- `modules/network/`: system networking capabilities such as local proxy integration
- `modules/security/`: SSH, TPM2, integrity checks, GitHub key sync
- `modules/presets/`: reusable host composition presets
- `modules/sessions/`: GNOME, Hyprland, greetd, Plymouth, and shared session defaults
- `packages/`: local package wrappers such as upstream Codex release packaging

## Hosts

### `c13`

- GNOME workstation preset
- ibus input method
- fractional scaling enabled through Home Manager dconf
- Caffeine/AppIndicator/GJS OSK GNOME extensions installed
- Clash Party is the default local proxy frontend
- Clash proxy defaults are exported through `desktop.proxy`, and Home Manager consumes the canonical `desktop.proxy.endpoints` interface
- `desktop.proxy.dnsPort` is the canonical Mihomo DNS upstream port shared by system and Home Manager config
- `systemd-resolved` remains the system stub on `127.0.0.53:53`; it forwards upstream DNS to `127.0.0.1:${desktop.proxy.dnsPort}`
- Clash Party TUN sidecars are materialized under `/var/lib/clash-party/sidecar` as root-owned setuid executables so the app does not need to mutate files in the Nix store
- Home Manager removes stale per-user `Clash Verge.desktop` autostart entries when Party is the selected frontend to avoid dual-frontend TUN/core races
- Clash Verge remains available as an alternative frontend by changing `desktop.clash.frontend`

### `t480s`

- Hyprland workstation preset
- `greetd` login flow
- Lanzaboote secure boot
- Btrfs swapfile + hibernation
- TLP power tuning

## Common workflows

Check the flake:

```bash
nix flake check
```

Build one host without switching:

```bash
nix build .#nixosConfigurations.c13.config.system.build.toplevel --no-link
nix build .#nixosConfigurations.t480s.config.system.build.toplevel --no-link
```

Switch the current machine:

```bash
sudo nixos-rebuild switch --flake .#c13
sudo nixos-rebuild switch --flake .#t480s
```

Update all inputs:

```bash
nix flake update
```

Update only Codex to the latest upstream release asset pinned in `flake.lock`:

```bash
nix flake update --update-input codex-upstream-bin
```

Gaming defaults live in `modules/apps/gaming.nix` and currently provide Steam, Lutris, 32-bit graphics support, GameMode, Gamescope, MangoHud, ProtonUp-Qt, Vulkan tools, and Winetricks across desktop hosts.

## Security and access

- OpenSSH password login is disabled
- root SSH login is disabled
- `bokutake` authorized keys are synced from `https://github.com/bokutake.keys`
- TPM2 and hibernation offset state are checked by `inazuma-security-scan`

## Notes

- `flake.lock` intentionally pins the content of the upstream Codex latest release asset even though the input URL points at `latest/download`
- the repository may be used from a dirty worktree during local iteration, but commits should be built at least once before push
- `home/bokutake/base.nix` carries the canonical Git identity and signing defaults for this repo
