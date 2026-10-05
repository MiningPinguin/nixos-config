# KDE Plasma configured through plasma-manager.
# Looks (colors, icons, cursor) are set in modules/theme/, behavior is set here.
{ inputs, ... }:
let
  user = "miningpinguin";
in
{
  home-manager.sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];

  home-manager.users.${user}.programs.plasma = {
    enable = true;
  };
}