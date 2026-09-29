{ pkgs, ... }: {
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Brussels";
  i18n.defaultLocale = "en_US.UTF-8";
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.miningpinguin = {
    isNormalUser = true;
    description = "MiningPinguin";
    extraGroups = [ "networkmanager" "wheel" ];
  };
}
