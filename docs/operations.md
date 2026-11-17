# Operations

## Rebuild

```bash
sudo nixos-rebuild switch --flake .#d-mk4
```

To update every input first:

```bash
nix flake update && sudo nixos-rebuild switch --flake .#d-mk4
```

`switch` builds the configuration, makes it the boot default and activates it. `boot` does the same build and makes it the boot default, but leaves the running system alone until the next reboot.

The hostname comes from the output name in the flake, so it is never a host-file edit. A new file must be staged with `git add` before a flake build can see it.

## Update report

The update service runs on login and reports which packages in the config have a newer version upstream. It then offers to copy a command that updates them.

It compares two evaluations of the config, never a build, and never writes `flake.lock`. A report therefore cannot turn into a change by itself.

The tracked input's upstream reference comes from the lock file, so moving a channel means editing one place. The service evaluates the config once with that revision overriding the input, and once as locked, then diffs the package lists.

Packages are read off the config rather than looked up by name. nixpkgs dropped the top-level KDE Gear aliases, so name lookup would silently miss most of the desktop.

A bump is collapsed by its from and to versions. Packages that share both become one line, and the pop-up speaks again only when that set changes. Dismissing it still counts as told.

Nix cannot update one package, so the copied command updates everything or nothing. It names the absolute config directory instead of `.`, so it works from any current directory.

The report waits for Plasma's notification server, because Plasma is not up yet when the graphical session starts. Copying goes through Klipper, because Wayland's clipboard tools have no display to talk to.

State lives under the user's XDG state directory. It caches the upstream evaluation and remembers the last announced set, so a login only asks the network once the tracked input has moved. Deleting that state costs nothing except the next login's check.

To see the report again:

```bash
rm ~/.local/state/nixos-config/seen
```

The config directory and the tracked input are options, so moving the flake or following a different channel is a config change, not a code change.
