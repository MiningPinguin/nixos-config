# Shared bits for the JetBrains IDEs: plugin ids, seed files, and KMM fetcher.
{ pkgs, inputs, ... }:
let
  lib = pkgs.lib;
  pluginDb = builtins.fromJSON (builtins.readFile
    "${inputs.nix-jetbrains-plugins}/generated/all_plugins.json");
  kmmPrefix = "com.jetbrains.kmm/--/";
in
{
  basePluginIds = [
    "izhangzhihao.rainbow.brackets"
    "intellij.prettierJS"
    "zielu.gittoolbox"
    "com.intellij.nativeDebug"
    "nix-idea"
    "org.toml.lang"
    "com.github.catppuccin.jetbrains"
  ];

  ideGeneralXml = ''
    <application>
      <component name="Registry">
        <entry key="ide.experimental.ui" value="true" source="SYSTEM" />
      </component>
    </application>
  '';

  androidSdkXml = ''
    <application>
      <component name="AndroidSdkPathStore">
        <option name="androidSdkAbsolutePath" value="$USER_HOME$/Android/Sdk" />
      </component>
    </application>
  '';

  kmmForIde = ide:
    let
      ideaMajor = builtins.head (lib.splitString "." ide.buildNumber);
      kmmVersions = map (lib.strings.removePrefix kmmPrefix) (
        builtins.filter (lib.strings.hasPrefix kmmPrefix) (builtins.attrNames pluginDb)
      );
      kmmVersion = lib.foldl' (
        best: v:
        let
          number = builtins.head (lib.splitString "-" v);
          bestNumber = builtins.head (lib.splitString "-" best);
        in
        if lib.strings.hasSuffix "-IJ" v
          && lib.strings.hasPrefix "${ideaMajor}." number
          && lib.versionAtLeast ide.buildNumber number
          && lib.versionAtLeast number bestNumber
        then v else best
      ) "0.0" kmmVersions;
      kmmEntry = pluginDb."${kmmPrefix}${kmmVersion}";
    in
    pkgs.fetchzip {
      name = "com.jetbrains.kmm-${kmmVersion}";
      url = "https://downloads.marketplace.jetbrains.com/${kmmEntry.p}";
      hash = "sha256-${kmmEntry.h}";
    };
}