{ pkgs, ... }: {
  # system side
  virtualisation.docker.enable = true;
  users.users.miningpinguin.extraGroups = [ "docker" ];
  environment.systemPackages = [ pkgs.docker-compose ];

  # user side (Home Manager)
  home-manager.users.miningpinguin = {
    programs.git = {
      enable = true;
      settings.user = { name = "YourName"; email = "you@example.com"; };
    };
    programs.vscode = { enable = true; package = pkgs.vscodium; };
    home.packages = with pkgs; [
      cmake ninja maven jdk nodejs
      godot kicad
      android-studio jetbrains-toolbox
      opencode llama-cpp-vulkan mutt
    ];
  };
}