# IntelliJ IDEA. Toolbox cannot be told which products to install: the list
# lives in .storage.json, which Toolbox rewrites on every run. Plugins come from
# a flake because nixpkgs' addPlugins takes only derivations.
{ inputs, pkgs, user, ... }:
let
  pluginIds = [
    "izhangzhihao.rainbow.brackets"
    "intellij.prettierJS"
    "zielu.gittoolbox"
    "com.intellij.spring.debugger"
    
    "org.jetbrains.android"
    "com.android.tools.design"
    "androidx.compose.plugins.idea"
    "com.intellij.nativeDebug"
    "org.jetbrains.kotlin-toolchain"
    "com.jetbrains.kmm"
    
    "com.intellij.swagger"
    "nix-idea"
    "org.toml.lang"
  ];
  plugins = builtins.attrValues (inputs.nix-jetbrains-plugins.lib.pluginsForIde
    pkgs pkgs.jetbrains.idea pluginIds);
in
{
  home-manager.users.${user}.home.packages = [
    (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.idea plugins)
  ];
}
