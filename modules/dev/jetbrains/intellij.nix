# IntelliJ IDEA. Toolbox cannot be told which products to install: the list
# lives in .storage.json, which Toolbox rewrites on every run. Plugins come from
# a flake because nixpkgs' addPlugins takes only derivations.
{ inputs, pkgs, user, ... }:
let
  common = import ./common.nix { inherit pkgs; };

  # com.jetbrains.kmm is fetched directly: nix-jetbrains-plugins selects the
  # Android Studio variant for IntelliJ IDEA, which declares the same
  # com.intellij.modules.nativeDebug module as the Native Debugging Support
  # plugin and depends on com.intellij.modules.androidstudio (absent in IDEA).
  kmmPlugin = pkgs.fetchzip {
    name = "com.jetbrains.kmm-262.10968.207-IJ";
    url = "https://downloads.marketplace.jetbrains.com/files/14936/1188704/kmm-plugin-262.10968.207-IJ.zip";
    sha256 = "10p6ninpbg4psbxb6j8m66rb2v7yc28wk5nfzxa2h38hdqvvwlif";
    stripRoot = true;
  };

  pluginIds = common.basePluginIds ++ [
    "com.intellij.spring.debugger"
    "com.intellij.swagger"
  ];
  plugins = builtins.attrValues (inputs.nix-jetbrains-plugins.lib.pluginsForIde
    pkgs pkgs.jetbrains.idea pluginIds) ++ [ kmmPlugin ];

  idea = pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.idea plugins;

  ideaWrapper = pkgs.writeShellScriptBin "intellij-idea" ''
    export IDEA_PROPERTIES=/home/${user}/.config/intellij/idea.properties
    exec ${pkgs.lib.getExe idea} "$@"
  '';
in
{
  home-manager.users.${user} = { config, ... }: {
    home.packages = [ ideaWrapper ];

    xdg.desktopEntries.intellij-idea = {
      name = "IntelliJ IDEA";
      exec = "intellij-idea";
      icon = "${idea}/intellij-idea/bin/idea.png";
      categories = [ "Development" "IDE" ];
    };

    xdg.configFile."intellij/idea.properties".text = ''
      idea.config.path=/home/${user}/.config/intellij/config
      idea.system.path=/home/${user}/.config/intellij/system
    '';

    xdg.configFile."intellij/config/options/ide.general.xml".text =
      common.ideGeneralXml;
  };
}
