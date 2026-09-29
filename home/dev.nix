{ pkgs, ... }: {
  home.username = "miningpinguin";
  home.homeDirectory = "/home/miningpinguin";
  home.stateVersion = "26.05";

  programs.git = {
    enable = true;
    settings.user = {
      name = "MiningPinguin";
      email = "Arthur+Github@ruymen.com";
    };
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
  };
}
