# nixos-config

Flake-based NixOS configuration for my machines.

| Host   | Role           | Modules                                          |
|--------|----------------|--------------------------------------------------|
| d-mk4  | desktop        | common, user, tools, dev, desktop, gaming, plasma, theme |
| l-mk1  | laptop         | common, user, tools, dev, desktop                |
| s-mk1  | file server    | common, user, tools, servers/base, servers/fileserver |
| s2-mk1 | network server | common, user, tools, servers/base, servers/network |

## Layout

- `flake.nix` defines the inputs, the username, and one output per host.
- `hosts/<name>/` holds what is specific to one machine: its module list,
  hardware configuration and boot setup.
- `modules/` is grouped by type, not by program. A module holds the NixOS and
  Home Manager settings for its topic together.
- `modules/theme/` is the only place that decides how things look. Each file
  there is a complete backend (currently `catppuccin.nix`), so switching theme
  system means swapping one import in the host.

## Rules

- A setting is defined once. The username lives in `flake.nix`; the theme
  flavor and accent live in `modules/theme/catppuccin.nix`.
- `user.nix` configures the account only. Programs live in the module for
  their topic.
- Looks live in `modules/theme/`, behavior lives in the module for the topic
  (for example `modules/plasma.nix`).

## Rebuilding

```
sudo nixos-rebuild switch --flake .#<host>
```

Use `boot` instead of `switch` for changes to the bootloader or hostname.
New files must be staged with `git add` before a flake build can see them.