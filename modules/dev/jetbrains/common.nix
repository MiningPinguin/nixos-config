# Shared bits for the JetBrains IDEs: plugin ids and seed files.
{ pkgs, ... }:
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
}
