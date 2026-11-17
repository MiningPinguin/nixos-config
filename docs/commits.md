# Commits

Commit subjects follow:

```
<scope>: <imperative verb> <object>
```

One line, no body.

## Scope

Scope is who the change is for, not how many files it touches.

- A change that only one machine needs gets that host's name, such as `d-mk4`.
- A change to one shared topic gets the topic's name, such as `sync`, `dev`, `theme` or `flake`.
- A change spanning several topics gets `repo`. That covers a rename, a new host, or a sweep of dead code.

## Subject

- Lowercase, and no trailing period.
- Capitals only for proper nouns and code, as in `README`, `GRUB` or `programs.vscodium`.
- Name the change itself, not the act of changing it.
- Bundle related edits into one commit, joining them with commas.

Examples from this repository:

```
d-mk4: add Wake-on-LAN and tailnet SSH
sync: scope and extend the pinkytime ignore rules
dev: add nix-ld libraries for prebuilt binaries
repo: rename d-mk1 to d-mk4
```
