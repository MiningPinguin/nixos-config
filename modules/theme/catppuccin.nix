# Catppuccin theming for NixOS, Home Manager and Plasma.
# Note: the Plasma part needs modules/plasma.nix (plasma-manager) imported too.
#
# Plasma's dark mode switch swaps the whole global theme and defaults to Breeze,
# so both sides are named below and lightFlavor is what it switches to.
#
# The cursor aliases work around nixpkgs' catppuccin-kde 0.2.6, whose global
# themes ask for Catppuccin-<Flavor>-<Accent>-Cursors while catppuccin-cursors
# installs catppuccin-<flavor>-<accent>-cursors, which Plasma matches exactly.
# NixOS/nixpkgs#543097 bumps past that but has sat unbuilt since 2026-07-18, so
# drop home.file and cursorSource once it lands.
{ inputs, lib, pkgs, user, ... }:let
  # Change the look here (flavors: latte, frappe, macchiato, mocha)
  flavor = "mocha";
  accent = "mauve";
  lightFlavor = "latte";
  # Catppuccin ships no icon theme.
  iconTheme = "breeze";

  cap = s: lib.toUpper (builtins.substring 0 1 s)
    + builtins.substring 1 (builtins.stringLength s) s;
  capFlavor = cap flavor;
  capAccent = cap accent;

  globalTheme = f: "Catppuccin-${cap f}-${capAccent}";
  cursorTheme = f: "catppuccin-${f}-${accent}-cursors";

  cursorSource = f:
    let
      system = pkgs.stdenv.hostPlatform.system;
      variant = "${f}${lib.toSentenceCase accent}";
    in
    "${inputs.catppuccin.packages.${system}.cursors.${variant}}/share/icons/${cursorTheme f}";

  kde = pkgs.catppuccin-kde.override {
    flavour = [ flavor lightFlavor ];
    accents = [ accent ];
  };
in
{
  imports = [ inputs.catppuccin.nixosModules.catppuccin ];
  catppuccin = { enable = true; autoEnable = true; inherit flavor accent; };

  home-manager.sharedModules = [ inputs.catppuccin.homeModules.catppuccin ];
  home-manager.users.${user} = {
    # Required by Home Manager since it stopped inferring this.
    # Extract to a shared module if another backend needs it.
    home.pointerCursor.enable = true;

    catppuccin = {
      enable = true;
      autoEnable = true;
      inherit flavor accent;
      vscode.profiles.default.enable = true;
      cursors.enable = true;
    };

    home.packages = [ kde ];

    home.file = {
      ".local/share/icons/${globalTheme flavor}-Cursors".source = cursorSource flavor;
      ".local/share/icons/${globalTheme lightFlavor}-Cursors".source = cursorSource lightFlavor;
    };

    # JetBrains IDEs read their color scheme from a seed file, so the look
    # follows the central flavor here instead of being named in modules/dev.
    xdg.configFile."intellij/config/options/colors.scheme.xml".text = ''
      <application>
        <component name="EditorColorsManagerImpl">
          <global_color_scheme name="Catppuccin ${capFlavor}" />
        </component>
      </application>
    '';

    xdg.configFile."intellij/config/options/laf.xml".text = ''
      <application>
        <component name="LafManager">
          <laf themeId="com.github.catppuccin.${flavor}.islands.jetbrains" />
        </component>
      </application>
    '';

    xdg.configFile."android-studio/config/options/colors.scheme.xml".text = ''
      <application>
        <component name="EditorColorsManagerImpl">
          <global_color_scheme name="Catppuccin ${capFlavor}" />
        </component>
      </application>
    '';

    xdg.configFile."android-studio/config/options/laf.xml".text = ''
      <application>
        <component name="LafManager">
          <laf themeId="com.github.catppuccin.${flavor}.islands.jetbrains" />
        </component>
      </application>
    '';
    programs.plasma.workspace = {
      lookAndFeel = globalTheme flavor;
      colorScheme = "Catppuccin${capFlavor}${capAccent}";
      cursor.theme = cursorTheme flavor;
      inherit iconTheme;
    };

    programs.plasma.configFile.kdeglobals = {
      KDE = {
        DefaultDarkLookAndFeel = globalTheme flavor;
        DefaultLightLookAndFeel = globalTheme lightFlavor;
      };
      # Breeze's global themes revert this key, so re-assert it every time.
      Icons.Theme = iconTheme;
    };
  };
}
