# IntelliJ IDEA. Toolbox cannot be told which products to install: the list
# lives in .storage.json, which Toolbox rewrites on every run. Plugins come from
# a flake because nixpkgs' addPlugins takes only derivations.
{ inputs, pkgs, user, ... }:
let
  common = import ./common.nix { inherit pkgs inputs; };

  pluginIds = common.basePluginIds ++ [
    "com.intellij.spring.debugger"
    "com.intellij.swagger"
    "org.jetbrains.android"
    "androidx.compose.plugins.idea"
    "org.jetbrains.kotlin-toolchain"
  ];
  plugins = builtins.attrValues (inputs.nix-jetbrains-plugins.lib.pluginsForIde
    pkgs pkgs.jetbrains.idea pluginIds);

  pluginDir = pkgs.linkFarmFromDrvs "intellij-plugins" plugins;

  ideaWrapper = pkgs.writeShellScriptBin "intellij-idea" ''
    export IDEA_PROPERTIES=/home/${user}/.config/intellij/idea.properties
    exec ${pkgs.lib.getExe pkgs.jetbrains.idea} "$@"
  '';
in
{
  home-manager.users.${user} = {
    home.packages = [ ideaWrapper ];

    xdg.desktopEntries.intellij-idea = {
      name = "IntelliJ IDEA";
      exec = "intellij-idea";
      icon = "${pkgs.jetbrains.idea}/intellij-idea/bin/idea.png";
      categories = [ "Development" "IDE" ];
    };

    home.file.".config/intellij/config/plugins" = {
      source = pluginDir;
      recursive = true;
    };

    xdg.configFile."intellij/idea.properties".text = ''
      idea.config.path=/home/${user}/.config/intellij/config
      idea.system.path=/home/${user}/.config/intellij/system
      idea.plugins.path=/home/${user}/.config/intellij/config/plugins
      idea.log.path=/home/${user}/.config/intellij/system/log
    '';
  };
}