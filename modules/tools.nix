# Small command line tools that are handy on any machine, desktop or server.
{ pkgs, user, ... }:
{
  environment.systemPackages = with pkgs; [
    # Reading and editing
    less
    nano
    vim

    # Moving files around
    rsync
    wget
    zip

    # Living in a shell
    htop
    tmux
    tree

    # Looking at the network and the hardware
    nmap
    smartmontools
    wirelesstools

    # USB sticks, external disks and repartitioning
    dosfstools
    exfatprogs
    gptfdisk
    mtools
    ntfs3g

    xdg-utils
  ];

  # Git, with the identity used for commits
  home-manager.users.${user}.programs.git = {
    enable = true;
    settings.user = {
      name = "MiningPinguin";
      email = "Arthur+Github@ruymen.com";
    };
  };
}
