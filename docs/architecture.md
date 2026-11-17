# Architecture

All hosts come out of one flake. The host files decide which shared modules to import; the modules decide what those settings are. Nothing else chooses between machines.

## Hosts and channels

There are two channels: stable and unstable. The graphical hosts follow unstable because they want newer kernels and toolchains, and the desktop also wants newer KDE. The servers follow stable because they have no such need.

The desktop-facing inputs follow unstable as well, because they are only used on the unstable hosts. That keeps one nixpkgs instance behind the modules that share packages with it.

`mkHost` sets the hostname from the output name and passes the flake inputs and username to every host. A hostname is therefore never a host-file edit.

A host without a hardware configuration yet imports it conditionally, so the flake still evaluates before the installer has written one.

## Rules

- Every setting is defined in exactly one place.
- A host selects modules; it does not configure them.
- A module is host-agnostic. Adding it to a second host means importing it, never editing it, even if one host is its only user today.
- The account is set up apart from the programs it uses.
- Appearance is decided centrally. Topic modules never hardcode a theme, colour or icon.

The reverse of the second and third rules does not work: reaching into the modules from a host to override a topic, or adding an `if host == ...` guard to a shared module. Both put a decision in two places, and the second place is the one nobody reads later.

## Examples

- Changing the look means editing the theme module. Plasma, the editors and the cursor follow because none of them name a colour.
- A second theme system means a new theme module, imported by the hosts that want it.
- A setting every host wants belongs in the shared modules, not in each host.
- A setting one host wants belongs in that host's directory, not in a module that would then need a condition to avoid changing the others.

## Account and home

The user module creates the one interactive account and its Home Manager profile. It also makes packages come from the host's channel instead of a second nixpkgs instance.

The account is separate from the programs the account runs. The Git identity therefore lives with the command-line tools, not with the user.

## Servers

The headless hosts share a base module with SSH and root login disabled. Each then imports one role: file sharing or the firewall-only network role.

A new server role is a new module plus an import in the host that wants it. No shared module grows a flag for it.

## Hardware graphics

Nothing in this repository sets `hardware.graphics.enable`. The desktop's X server counts as a graphical desktop, so nixpkgs turns it on with a default.

Two things depend on it and fail without a useful error:

- Wine loses its 32-bit drivers.
- llama-swap's Vulkan drivers stop loading on the desktop.

If either breaks, read nixpkgs' graphical-desktop module first, then set `hardware.graphics.enable = true` in the desktop module. The headless servers do not need it.
