# nixos-config

Flake-based NixOS configuration for my machines.

| Host   | Role           | Purpose                |
|--------|----------------|------------------------|
| d-mk4  | desktop        | gaming + development   |
| l-mk1  | laptop         | development            |
| s-mk1  | file server    | fileserver + docker    |
| s2-mk1 | network server | networking             |

## Layout

- `flake.nix` — flake inputs, the username, one output per host.
- `hosts/<name>/` — what is specific to one machine: module list, hardware, boot, storage.
- `modules/` — shared settings grouped by topic, not by program. A topic's NixOS and Home Manager options live in the same file.
- `modules/theme/` — appearance. One file per backend.

## Rules

- Every setting is defined in exactly one place.
- A host selects modules; it does not configure them.
- A module is host-agnostic. Adding it to a second host means importing it, never editing it, even if one host is its only user today.
- The account is set up apart from the programs it uses.
- Appearance is decided centrally. Topics never hardcode a theme, colour or icon.

## Commits

`<scope>: <imperative verb> <object>`, one line, no body.

- Scope is who the change is for, not how many files it touches.
- A change that only one machine needs gets that host's name.
- A change to one shared topic gets the topic's name.
- A change spanning several topics — a rename, a new host, a sweep of dead code — gets `repo`.
- Lowercase, and no trailing period.
- Capitals only for proper nouns and code, as in `README`, `GRUB`, `programs.vscodium`.
- Name the change itself, not the act of changing.
- Bundle related edits into one commit, joined with commas.

## Example

- Changing the look means editing `flavor` and `accent` in `modules/theme/catppuccin.nix`.
  - Plasma, editors, terminals and cursors follow, because none of them name a colour.
  - No host file changes, because no host file ever held the choice.
- A second theme system means a new file in `modules/theme/`, imported by the hosts that want it, and nothing else changes.
- The same holds outside appearance.
  - A setting every host wants belongs in `modules/`, not in each host.
  - A setting one host wants belongs in `hosts/<name>/`, not in a module that would then need a condition to avoid changing the others.
- What does not work is the reverse: reaching into `modules/` from a host to override a topic, or adding an `if host == ...` guard to a shared module.
  - Both put a decision in two places, and the second place is the one nobody reads.

## Rebuilding

```
sudo nixos-rebuild switch --flake .#<host>
```

Use `boot` instead of `switch` for bootloader or hostname changes.
New files must be staged with `git add` before a flake build can see them.