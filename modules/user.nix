# The interactive user and the Home Manager bits that go with them.
{ pkgs, ... }:
let
  user = "miningpinguin";
in
{
  users.users.${user} = {
    isNormalUser = true;
    description = "MiningPinguin";
    extraGroups = [ "networkmanager" "wheel" ];
    # Passwords are set on the machine (`passwd miningpinguin`), or by
    # uncommenting this and hashing a password with `mkpasswd`.
    # initialHashedPassword = "";
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.${user} = {
    home.username = user;
    home.homeDirectory = "/home/${user}";
    home.stateVersion = "26.05";

    programs.git = {
      enable = true;
      settings.user = {
        name = "MiningPinguin";
        email = "Arthur+Github@ruymen.com";
      };
    };

    programs.vscodium = {
      enable = true;
      profiles.default.userSettings."git.autofetch" = true;
    };
  };
}
