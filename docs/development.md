# Development

The development module is shared by the graphical hosts. It provides containers, a database, the language toolchains and the editors. The module itself is the list; this page covers why it is built the way it is.

## Toolchains

The Android SDK is deliberately mutable outside Nix, because the IDE and its tools expect to install and update SDK packages themselves. The environment points the tools at that directory.

`programs.nix-ld` lets prebuilt binaries that expect an FHS layout run without packaging each one.

## VSCodium

Extensions come from nixpkgs, at nixpkgs' version rather than the marketplace's, and only if nixpkgs packages them. That keeps the editor reproducible, at the cost of lagging behind the marketplace.

An extension pack installs the pack alone, not its members. The Java extensions are therefore listed one by one.

The Nix language server points at this flake. Its NixOS and Home Manager option expressions are built from the current hostname, so completion follows the machine being edited.

## IntelliJ IDEA and Android Studio

Both IDEs keep their config, plugins and logs in a predictable location instead of spreading them through the home directory. Both also get a desktop entry for the launcher and the task manager.

Plugins come from the `nix-jetbrains-plugins` flake rather than nixpkgs' helper, because the helper takes only derivations.

Some plugins need exceptions:

- The Kotlin Multiplatform plugin is fetched directly for IntelliJ IDEA. The flake chooses the Android Studio variant, which declares the same native-debug module as the separate Native Debugging Support plugin and depends on an Android Studio module that IDEA does not have.
- Android Studio ships its own native-debug support inside the KMP plugin, so the separate Native Debugging Support plugin is absent there.
- Prettier is absent from Android Studio because it needs the JavaScript analysis plugin, which Android Studio does not ship.

Android Studio's first-run marker is written so the IDE does not ask for the SDK location again.

JetBrains Toolbox cannot be told which products to install: that list lives in a file Toolbox rewrites on every run. Products are therefore packaged by Nix, and the marketplace is left out of the decision.

The Catppuccin colour scheme and look-and-feel seeds come from the theme module; see [Desktop](desktop.md#theme).
