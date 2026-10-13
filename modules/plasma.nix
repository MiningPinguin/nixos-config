# KDE Plasma: session, display manager, KDE applications and the user
# configuration through plasma-manager (panels, behavior).
# Looks (colors, icons, cursor) are set in modules/theme/.
{ inputs, pkgs, user, ... }:
{
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

  home-manager.sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];

  home-manager.users.${user}.programs.plasma = {
    enable = true;

    # The layout is applied by a startup script on the next login after a
    # rebuild, replacing any panel edits made by hand.
    panels = [
      # Applications: what you launch and switch to.
      {
        location = "bottom";
        screen = "all";
        lengthMode = "fit";
        alignment = "left";
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
              "applications:intellij-idea.desktop"
              "applications:md.obsidian.Obsidian.desktop"
            ];
          }
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.showdesktop"
        ];
      }

      # Status: what the machine is telling you.
      {
        location = "bottom";
        height = 32;
        screen = "all";
        lengthMode = "fit";
        alignment = "right";
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
