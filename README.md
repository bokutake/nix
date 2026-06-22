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
│   ├── core/
│   ├── desktop/
│   ├── hardware/
│   ├── presets/
│   └── security/
└── packages/
```

## Structure

- `hosts/<name>/`: machine-specific assembly and overrides
- `home/bokutake/`: Home Manager configuration for the primary user
- `modules/core/`: locale, Nix settings, users, base packages
- `modules/desktop/`: desktop stack, apps, GNOME, Hyprland, Clash Verge
- `modules/hardware/`: reusable hardware support modules
- `modules/security/`: SSH, TPM2, integrity checks, GitHub key sync
- `modules/presets/`: reusable host composition presets
- `packages/`: local package wrappers such as upstream Codex release packaging

## Hosts

### `c13`

- GNOME + GDM
- ibus input method
- fractional scaling enabled through Home Manager dconf
- Caffeine/AppIndicator/GJS OSK GNOME extensions installed
- Clash Verge enabled, autostarted, and used as the `nix-daemon` proxy via `socks5h://127.0.0.1:7897`

### `t480s`

- Hyprland preset
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

## Security and access

- OpenSSH password login is disabled
- root SSH login is disabled
- `bokutake` authorized keys are synced from `https://github.com/bokutake.keys`
- TPM2 and hibernation offset state are checked by `inazuma-security-scan`

## Notes

- `flake.lock` intentionally pins the content of the upstream Codex latest release asset even though the input URL points at `latest/download`
- the repository may be used from a dirty worktree during local iteration, but commits should be built at least once before push
- `home/bokutake/base.nix` carries the canonical Git identity and signing defaults for this repo
