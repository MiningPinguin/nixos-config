# KDE Plasma: session, display manager, KDE applications and the user
# configuration through plasma-manager (panels, behavior).
# Looks (colors, icons, cursor) are set in modules/theme/.
{ inputs, pkgs, user, ... }:
{
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

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

  home-manager.sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];

  home-manager.users.${user}.programs.plasma = {
    enable = true;

    # The layout is applied by a startup script on the next login after a
    # rebuild, replacing any panel edits made by hand.
    panels = [
      # Bottom: launcher and pinned apps, on every screen.
      {
        location = "bottom";
        screen = "all";
        lengthMode = "fit";
        alignment = "center";
        hiding = "dodgewindows";
        floating = true;
        opacity = "translucent";
        widgets = [
          "org.kde.plasma.kickoff"
          {
            iconTasks.launchers = [
              "applications:org.kde.dolphin.desktop"
              "applications:firefox.desktop"
              "applications:discord.desktop"
              "applications:spotify.desktop"
              "applications:codium.desktop"
            ];
          }
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.showdesktop"
        ];
      }

      # Top: system tray and clock, on every screen.
      {
        location = "top";
        height = 32;
        screen = "all";
        lengthMode = "fit";
        alignment = "center";
        hiding = "dodgewindows";
        floating = true;
        opacity = "translucent";
        widgets = [
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
        ];
      }
    ];
  };
}
