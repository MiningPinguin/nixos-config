# The interactive user and their Home Manager account.
# The programs they use live in the modules grouped by type.
{ user, ... }:
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
  };
}