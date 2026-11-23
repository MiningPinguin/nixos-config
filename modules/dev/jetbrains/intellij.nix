# IntelliJ IDEA. Toolbox cannot be told which products to install: the list
# lives in .storage.json, which Toolbox rewrites on every run. Plugins come from
# a flake because nixpkgs' addPlugins takes only derivations.
{ inputs, pkgs, pkgs-stable, user, ... }:
let
  lib = pkgs-stable.lib;
  pluginDb = builtins.fromJSON (builtins.readFile
    "${inputs.nix-jetbrains-plugins}/generated/all_plugins.json");
  kmmPrefix = "com.jetbrains.kmm/--/";

  # pluginsForIde picks -AS builds for IntelliJ, so we find the best -IJ entry
  # whose build number is <= the IDE's build number.
  kmm =
    let
      buildNumber = pkgs-stable.jetbrains.idea.buildNumber;
      ijVersions = map (lib.removePrefix kmmPrefix) (
        builtins.filter (k:
          lib.hasPrefix kmmPrefix k && lib.hasSuffix "-IJ" (lib.removePrefix kmmPrefix k)
        ) (builtins.attrNames pluginDb)
      );
      best = lib.foldl' (best: v:
        let
          vNum = lib.removeSuffix "-IJ" v;
          bestNum = lib.removeSuffix "-IJ" best;
        in
        if lib.versionAtLeast buildNumber vNum && lib.versionAtLeast vNum bestNum
        then v else best
      ) "0.0-IJ" ijVersions;
      entry = pluginDb."${kmmPrefix}${best}";
    in
    pkgs-stable.fetchzip {
      name = "com.jetbrains.kmm-${best}";
      url = "https://downloads.marketplace.jetbrains.com/${entry.p}";
      hash = "sha256-${entry.h}";
    };

  pluginIds = [
    "izhangzhihao.rainbow.brackets"
    "intellij.prettierJS"
    "zielu.gittoolbox"
    "com.intellij.nativeDebug"
    "nix-idea"
    "org.toml.lang"
    "com.github.catppuccin.jetbrains"
    "com.intellij.spring.debugger"
    "com.intellij.swagger"
    "com.intellij.marketplace"
    "org.jetbrains.android"
    "androidx.compose.plugins.idea"
    "org.jetbrains.kotlin-toolchain"
  ];
  plugins = builtins.attrValues (inputs.nix-jetbrains-plugins.lib.pluginsForIde
    pkgs-stable pkgs-stable.jetbrains.idea pluginIds)
    ++ [ kmm ];

  pluginDir = pkgs.linkFarmFromDrvs "intellij-plugins" plugins;

  ideaWrapper = pkgs.writeShellScriptBin "intellij-idea" ''
    export IDEA_PROPERTIES=/home/${user}/.config/intellij/idea.properties
    exec ${pkgs.lib.getExe pkgs-stable.jetbrains.idea} "$@"
  '';
in
{
  home-manager.users.${user} = {
    home.packages = [ ideaWrapper ];

    xdg.desktopEntries.intellij-idea = {
      name = "IntelliJ IDEA";
      exec = "intellij-idea";
      icon = "${pkgs-stable.jetbrains.idea}/intellij-idea/bin/idea.png";
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

    xdg.configFile."intellij/config/options/androidSdk.xml".text = ''
      <application>
        <component name="AndroidSdkPathStore">
          <option name="androidSdkAbsolutePath" value="$USER_HOME$/Android/Sdk" />
        </component>
      </application>
    '';
  };
}