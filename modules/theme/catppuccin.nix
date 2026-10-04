# Catppuccin theming for NixOS, Home Manager and Plasma.
# To switch theme backend later (e.g. Stylix), replace this file's import in
# the host with a different module from this folder.
# Note: the Plasma part needs modules/plasma.nix (plasma-manager) imported too.
{ inputs, lib, pkgs, user, ... }:let
  # Change the look here (flavors: latte, frappe, macchiato, mocha)
  flavor = "mocha";
  accent = "mauve";

  # Plasma's theme names are capitalized: mocha -> Mocha
  cap = s: lib.toUpper (builtins.substring 0 1 s)
    + builtins.substring 1 (builtins.stringLength s) s;
  capFlavor = cap flavor;
  capAccent = cap accent;

  kde = pkgs.catppuccin-kde.override {
    flavour = [ flavor ];
    accents = [ accent ];
  };
in
{
  imports = [ inputs.catppuccin.nixosModules.catppuccin ];
  catppuccin = { enable = true; autoEnable = true; inherit flavor accent; };

  home-manager.sharedModules = [ inputs.catppuccin.homeModules.catppuccin ];
  home-manager.users.${user} = {
    catppuccin = {
      enable = true;
      autoEnable = true;
      inherit flavor accent;
      vscode.profiles.default.enable = true;
      cursors.enable = true;
    };

    home.packages = [ kde ];

    programs.plasma.workspace = {
      lookAndFeel = "Catppuccin-${capFlavor}-${capAccent}";
      colorScheme = "Catppuccin${capFlavor}${capAccent}";
      cursor.theme = "catppuccin-${flavor}-${accent}-cursors";
    };
  };
}