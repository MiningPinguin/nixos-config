# VSCodium, with the Nix language server reading this flake.
{ config, user, ... }:
{
  home-manager.users.${user}.programs.vscodium = {
    enable = true;
    profiles.default = {
      userSettings = {
        "git.autofetch" = true;
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.serverSettings".nixd = {
          formatting.command = [ "nixfmt" ];
          options = {
            nixos.expr = ''
              (builtins.getFlake "/home/${user}/nixos-config")
                .nixosConfigurations.${config.networking.hostName}.options
            '';
            home-manager.expr = ''
              (builtins.getFlake "/home/${user}/nixos-config")
                .nixosConfigurations.${config.networking.hostName}
                .options.home-manager.users.type.getSubOptions []
            '';
          };
        };
      };
    };
  };
}