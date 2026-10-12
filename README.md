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
- `hosts/<name>/` — what is specific to one machine.
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

## Known limitations

### Lock screen

- SDDM draws the login screen and kscreenlocker draws the lock screen: separate programs, separate settings ([SDDM's maintainer on this](https://github.com/sddm/sddm/issues/721)).
  - Nothing binds them together.
  - nixpkgs has no option over either one, so there is nowhere to put a shared decision.
- Up to Plasma 6.0 a theme could supply one via `contents/lockscreen/LockScreen.qml` in its global theme ([porting guide](https://develop.kde.org/docs/plasma/theme/theme-porting-to-plasma6)).
  - Both surfaces then came from the same file, so one theme file covered both.
- Since Plasma 6.1 it comes from the Plasma shell package instead ([source](https://invent.kde.org/plasma/kscreenlocker/-/blob/master/settings/shell_integration.cpp)).
  - The global theme lost that hook, so a theme can no longer supply a lock screen.
  - Breeze, the theme Plasma itself ships, does not provide one either.
- No theme fills the gap.
  - `catppuccin-kde` has only a splash screen.
  - Neither nixpkgs nor the `catppuccin` flake packages a lock screen.

Recheck when any of these change:

- Plasma restores a lock screen component for global themes, or documents an equivalent for shell packages.
- `catppuccin-kde` or the `catppuccin` flake ships a lock screen.

## Updates

- On login, the desktop reports which packages in this config have newer versions upstream.
  - The pop-up carries a button that copies the command to update them, so the desktop itself never rebuilds anything.
- It compares two evaluations of the config, never a build.
  - It never writes `flake.lock`, so a report can never turn into a change.
- Packages are read off the config rather than looked up by name.
  - nixpkgs dropped the top-level KDE Gear aliases, so name lookup would silently miss most of the desktop.
- Nix cannot update one package, so the button updates everything or nothing.
- Bumps sharing a from and a to fold into one line, and the pop-up speaks only when that set changes.
- State lives in `~/.local/state/nixos-config/`.
  - Deleting it costs nothing but the next login's check.

To see the report again:

```
rm ~/.local/state/nixos-config/seen
```

## Local models

- `hosts/d-mk4/llm.nix` serves language models on d-mk4. Nothing runs until a client connects.
  - `llm.socket` accepts the connection on `127.0.0.1:8080`.
  - `llm.service` is `systemd-socket-proxyd`, forwarding to llama-swap on port 8081.
  - `llama-swap.service` reads the model out of the request, starts `llama-server` for it, and swaps models as they are asked for.
- Shutdown happens in two stages, because a model held in VRAM holds the GPU.
  - llama-swap unloads a model after 300 seconds without requests.
  - The proxy exits after 10 minutes without traffic, and systemd stops llama-swap with it.
- Models live on `/mnt/extra/models` and are listed in `models`.
  - Each gets a context of 120000 unless it names its own.
  - Adding one to that list is all it takes: opencode reads the same attribute set, so it shows up there too.
  - Nothing fetches them. The `.gguf` files have to be on that disk already.
- It needs `hardware.graphics`, which this config never sets on purpose.
  - nixpkgs turns it on for any host with an X server or a display manager. See the note in `modules/desktop.nix` for what to check when that stops being true.

## Rebuilding

```
sudo nixos-rebuild switch --flake .#$host
```

```
nix flake update && sudo nixos-rebuild switch --flake .#$host
```

Use `boot` instead of `switch` for bootloader or hostname changes.
New files must be staged with `git add` before a flake build can see them.