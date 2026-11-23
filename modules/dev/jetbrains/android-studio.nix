# Android Studio. Plugins come from the flake, SDK stays mutable in ~/Android/Sdk.
{ inputs, pkgs, user, ... }:
let
  # Android Studio ships its own native-debug module inside the KMP plugin,
  # so the separate Native Debugging Support plugin conflicts with it.
  # Prettier needs the JS analysis plugin, which AS does not ship.
  pluginIds = [
    "izhangzhihao.rainbow.brackets"
    "zielu.gittoolbox"
    "nix-idea"
    "org.toml.lang"
    "com.github.catppuccin.jetbrains"
    "com.intellij.marketplace"
    "org.jetbrains.kotlin-toolchain"
    "com.jetbrains.kmm"
  ];
  plugins = builtins.attrValues (inputs.nix-jetbrains-plugins.lib.pluginsForIde
    pkgs pkgs.android-studio pluginIds);

  pluginDir = pkgs.linkFarmFromDrvs "android-studio-plugins" plugins;
in
{
  home-manager.users.${user} = {
    home.packages = [ pkgs.android-studio ];

    home.sessionVariables.STUDIO_PROPERTIES =
      "/home/${user}/.config/android-studio/idea.properties";

    xdg.desktopEntries.android-studio = {
      name = "Android Studio";
      exec = "${pkgs.lib.getExe pkgs.android-studio}";
      icon = "${pkgs.android-studio}/share/pixmaps/android-studio.png";
      categories = [ "Development" "IDE" ];
    };

    home.file.".config/android-studio/config/plugins" = {
      source = pluginDir;
      recursive = true;
    };

    xdg.configFile."android-studio/idea.properties".text = ''
      idea.config.path=/home/${user}/.config/android-studio/config
      idea.system.path=/home/${user}/.config/android-studio/system
    '';
  };
}
