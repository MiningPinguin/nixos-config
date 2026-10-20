# Android Studio. Plugins come from the flake, SDK stays mutable in ~/Android/Sdk.
{ inputs, pkgs, user, ... }:
let
  common = import ./common.nix { inherit pkgs; };

  pluginIds = common.basePluginIds ++ [ "com.jetbrains.kmm" ];
  plugins = builtins.attrValues (inputs.nix-jetbrains-plugins.lib.pluginsForIde
    pkgs pkgs.android-studio pluginIds);

  pluginDir = pkgs.linkFarmFromDrvs "android-studio-plugins" plugins;

  androidStudio = pkgs.android-studio;

  androidStudioWrapper = pkgs.writeShellScriptBin "android-studio" ''
    export IDEA_PROPERTIES=/home/${user}/.config/android-studio/idea.properties
    exec ${pkgs.lib.getExe androidStudio} "$@"
  '';
in
{
  home-manager.users.${user} = { config, ... }: {
    home.packages = [ androidStudioWrapper ];

    xdg.desktopEntries.android-studio = {
      name = "Android Studio";
      exec = "android-studio";
      icon = "${androidStudio}/share/pixmaps/android-studio.png";
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

    xdg.configFile."android-studio/config/options/android.sdk.path.xml".text = ''
      <application>
        <component name="AndroidSdkPathStore">
          <option name="androidSdkAbsolutePath" value="$USER_HOME$/Android/Sdk" />
        </component>
      </application>
    '';

    xdg.configFile."android-studio/config/options/androidStudioFirstRun.xml".text = ''
      <application>
        <component name="AndroidFirstRunPersistentData">
          <version>1</version>
        </component>
      </application>
    '';

    xdg.configFile."android-studio/config/options/ide.general.xml".text =
      common.ideGeneralXml;
  };
}
