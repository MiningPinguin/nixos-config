# nixos-config

Flake-based NixOS configuration for my machines.

| Host   | Role           | Purpose                | NixOS     |
|--------|----------------|------------------------|-----------|
| d-mk4  | desktop        | gaming + development   | installed |
| l-mk1  | laptop         | development            | pending   |
| s-mk1  | file server    | fileserver + docker    | pending   |
| s2-mk1 | network server | networking             | pending   |

Only d-mk4 is on this config, so the commands under Rebuilding apply to it until the others are installed. A host can have an entry here before the machine is on NixOS.

## Layout

- `flake.nix` — flake inputs, the username, one output per host.
- `hosts/<name>/` — what is specific to one machine.
- `modules/` — shared settings grouped by topic, not by program. A topic's NixOS and Home Manager options live in the same file.
  - `modules/servers/` — what the headless machines share (`base.nix`, ssh) plus one file per role, so a host picks the service it runs.
  - `modules/dev/` — toolchains, with anything large enough to manage its own plugins in a file of its own.
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
  - nixpkgs turns it on for any host with an X server or a display manager, which `services.xserver.enable` counts as. Two things need it and would fail without a word of complaint: Wine loses its 32-bit drivers, and llama-swap's Vulkan drivers stop loading on d-mk4.
  - If either breaks, read `nixos/modules/services/misc/graphical-desktop.nix` in nixpkgs first, then set `hardware.graphics.enable = true` in `modules/desktop.nix`.

## Syncthing

- `~/Projects` is synced between d-mk4, s-mk1 and l-mk1.
- It is the Home Manager module, because `services.syncthing` runs as its own account and cannot read this user's home.
- Everything is declared in `modules/sync.nix`, so anything added in the GUI is gone at the next activation.
  - Until s-mk1 and l-mk1 are installed on this config, they declare the same folder and the same folder id (`miningpinguin-projects`) through their own Syncthing. Syncthing requires the folder and its id to match on every device, so changing either means changing them on all three.
- The GUI listens on loopback only, so reach it over SSH:

  ```
  ssh -L 8384:127.0.0.1:8384 d-mk4
  ```

- Replaced files are kept, 10 versions deep.
- Build output and editor droppings (`node_modules`, `target`, `build`, `.idea` and friends) are excluded rather than synced.

## Rebuilding

```
sudo nixos-rebuild switch --flake .#$host
```

```
nix flake update && sudo nixos-rebuild switch --flake .#$host
```

Use `boot` when a change should land at the next reboot rather than now. It builds the configuration and makes it the boot default, but does not activate it, so the running system stays as it is. `switch` does both, and is the right choice for everything else here.
Hostname comes from the host's name, set centrally in `flake.nix`, so it is never a host-file edit.
New files must be staged with `git add` before a flake build can see them.
