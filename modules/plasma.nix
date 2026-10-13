# KDE Plasma: session, display manager and KDE applications.
# The panel layout lives in modules/plasma/panels.nix.
# Looks (colors, icons, cursor) are set in modules/theme/.
{ pkgs, ... }:
{
  imports = [ ./plasma/panels.nix ];

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Phone bridge: file transfer, clipboard and notifications
  programs.kdeconnect.enable = true;

  environment.systemPackages = with pkgs; [
    kdePackages.ark
    kdePackages.dolphin
    kdePackages.kate
    kdePackages.kcalc
    kdePackages.kclock
    kdePackages.kgamma
    kdePackages.konsole
    kdePackages.partitionmanager
    kdePackages.plasma-sdk
    kdePackages.plymouth-kcm
  ];
}