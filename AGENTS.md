# AGENTS.md

This repository is a personal NixOS flake. Treat it as an actively used machine configuration, not as a generic template.

## Goals

- keep `c13` and `t480s` reproducible and buildable
- preserve the current module boundaries
- prefer small, composable modules over host-local monoliths
- do not regress boot, login, SSH access, swap, hibernation, or signing

## Repository conventions

### Top-level boundaries

- `hosts/` contains machine assembly and machine-only overrides
- `home/bokutake/` contains user-space Home Manager config
- `modules/` contains reusable NixOS modules grouped by domain
- `packages/` contains local package wrappers only

### Composition rules

- prefer static `imports` and gate behavior with options or `lib.mkIf`
- do not reference `config.*` from `imports`
- keep preset modules thin; presets should compose modules, not reimplement them
- if logic is host-specific, put it under the host directory instead of a shared module

### User config

- keep user-specific Home Manager settings under `home/bokutake/`
- avoid scattering `home-manager.users.bokutake` across system modules
- keep Git identity and signing defaults in `home/bokutake/base.nix`

### Security expectations

- do not re-enable SSH password auth or root SSH login without explicit request
- preserve GitHub authorized key sync unless explicitly replaced
- preserve TPM2/integrity scan behavior unless there is a clear regression fix

### Codex packaging

- `packages/codex-upstream.nix` wraps the upstream latest-release Linux binary
- `flake.nix` uses `codex-upstream-bin` as a non-flake input
- update Codex with `nix flake update --update-input codex-upstream-bin`
- do not switch back to source builds unless there is a concrete reason

## Change process

Before changing structure:

1. identify whether the change belongs in `hosts/`, `modules/`, `home/`, or `packages/`
2. prefer adding a focused module over growing an existing catch-all file
3. keep `README.md` accurate when workflows or structure change

Before committing:

1. run `nix flake check`
2. when relevant, build the target host with `nix build .#nixosConfigurations.<host>.config.system.build.toplevel --no-link`
3. avoid committing `.codex`

## Known machine intent

### `c13`

- GNOME machine
- Clash Verge expected on `127.0.0.1:7897`
- `nix-daemon` proxy should continue using `socks5h://127.0.0.1:7897`

### `t480s`

- Hyprland machine
- secure boot via Lanzaboote
- Btrfs swapfile and hibernation are intentional

## Avoid

- destructive Git commands unless explicitly requested
- reverting unrelated user changes
- broad aesthetic rewrites of config comments or formatting without payoff
- mixing documentation-only commits with behavior changes unless requested
