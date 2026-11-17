# nixos-config

Packages, services, users and the desktop are declared in Git, so a host is rebuilt from this repository instead of configured by hand.

| Host   | Role           | Purpose              | Channel  | Status    |
|--------|----------------|----------------------|----------|-----------|
| d-mk4  | desktop        | gaming + development | unstable | installed |
| l-mk1  | laptop         | development          | unstable | pending   |
| s-mk1  | file server    | Samba file sharing   | stable   | pending   |
| s2-mk1 | network server | networking           | stable   | pending   |

Only d-mk4 runs this config today. The other hosts have entries so the flake can be evaluated before their installs.

## Design Decisions

- **One flake, one output per host.** Every machine is built through the same `mkHost`, so its hostname and shared arguments cannot drift.
- **Stable and unstable side by side.** Servers follow NixOS 26.05; the desktop and laptop follow unstable, and the desktop-facing inputs follow unstable with them.
- **Modules describe topics, hosts select them.** A host never configures a shared module, and a module never checks which host is asking.
- **Appearance is decided once.** Flavor and accent live in `modules/theme/catppuccin.nix`; Plasma, the editors and the cursor derive from them.
- **Updates are reported, never applied.** A login check compares the locked config with upstream and copies a command; it never writes `flake.lock` on its own.
- **Models start on demand.** Socket activation keeps the GPU idle until a client connects, and llama-swap releases it after five idle minutes.

## Layout

```
flake.nix          inputs, channels, one output per host
hosts/<host>/      machine-specific boot, hardware, network and storage
modules/           shared settings, one file per topic
  dev/             editors and toolchains
  plasma/          panel layout
  servers/         headless base plus one file per role
  sync/            Syncthing folders and ignore rules
  theme/           appearance backend
docs/              why things are the way they are
```

## Rebuild

```bash
sudo nixos-rebuild switch --flake .#d-mk4
```

```bash
nix flake update && sudo nixos-rebuild switch --flake .#d-mk4
```

Use `boot` instead of `switch` when a change should land at the next reboot. New files must be staged with `git add` before a flake build can see them.

## Documentation

The README is the overview. The pages under `docs/` hold the reasoning and the operational detail.

| Page | What it answers |
|---|---|
| [Architecture](docs/architecture.md) | How the flake, hosts, channels and modules fit together |
| [Operations](docs/operations.md) | Rebuilding, updating inputs and the login update report |
| [Desktop](docs/desktop.md) | Plasma, panels, Catppuccin and the lock-screen limitation |
| [Development](docs/development.md) | Toolchains, VSCodium, JetBrains IDEs and Android |
| [Local models](docs/local-models.md) | Socket activation, on-demand loading and the GPU caveat |
| [Syncthing](docs/syncthing.md) | Why shares and ignore rules are declared in Nix |
| [Network](docs/network.md) | Wake-on-LAN and SSH over the tailnet |
| [Commits](docs/commits.md) | Commit message convention |
