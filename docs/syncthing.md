# Syncthing

The sync module shares project folders individually.

## Why Home Manager

It uses the Home Manager module, not the NixOS service, because the NixOS service runs as its own account and cannot read this user's home.

## Shared folders

A folder and its ID have to match on every device that shares it, so the same shares must be declared on the other machines too.

An aggregate share of the whole projects directory was retired in favour of per-folder shares. Individual shares keep unrelated files out of sync and let each folder carry its own ignore rules.

Everything is declared in the module, so anything added through the GUI is gone at the next activation.

## Ignore rules

Ignore rules are declared in Nix, because `.stignore` is per-device and never syncs over. Nix writes them into each folder's settings.

## Versioning

Simple versioning keeps replaced files around, so a bad sync can be undone.

## Access

The GUI listens on loopback only. Reach it over SSH:

```bash
ssh -L 3000:127.0.0.1:8384 miningpinguin@s-mk1
```

Then open `http://127.0.0.1:3000`.
