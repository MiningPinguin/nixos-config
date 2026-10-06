# d-mk4: desktop with a plasma session, used for development and gaming.
{
  imports = [
    ./boot.nix
    ./hardware-configuration.nix
    ./storage.nix
    ../../modules/common.nix
    ../../modules/user.nix
    ../../modules/tools.nix
    ../../modules/dev.nix
    ../../modules/desktop.nix
    ../../modules/gaming.nix
    ../../modules/plasma.nix
    ../../modules/theme/catppuccin.nix
  ];

  system.stateVersion = "26.05";
}