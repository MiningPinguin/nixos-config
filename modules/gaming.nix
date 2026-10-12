# Inert unless hardware.graphics.enable is on, which nixpkgs does for any
# graphical desktop. The README explains what depends on it.
{ pkgs, ... }: {
  hardware.graphics.enable32Bit = true;

  programs.steam = {
    enable = true;
    protontricks.enable = true;
  };

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    heroic
    prismlauncher
    wineWow64Packages.stable
    winetricks
  ];
}