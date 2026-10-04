# KDE Plasma configured through plasma-manager.
# Looks (colors, icons, cursor) are set in modules/theme/, behavior is set here.
{ inputs, user, ... }:
{
  home-manager.sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];

  home-manager.users.${user}.programs.plasma = {
    enable = true;
  };
}