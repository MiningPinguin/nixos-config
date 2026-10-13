# VSCodium, with the Nix language server reading this flake.
{ config, pkgs, user, ... }:
{
  home-manager.users.${user}.programs.vscodium = {
    enable = true;
    profiles.default = {
      # Home Manager installs the extensions listed here and nothing else, so
      # the members of a pack are spelled out instead of the pack.
      extensions = with pkgs.vscode-extensions; [
        # Editing and formatting
        adpyke.codesnap
        bradlc.vscode-tailwindcss
        dbaeumer.vscode-eslint
        mechatroner.rainbow-csv
        prettier.prettier-vscode
        usernamehw.errorlens

        # Writing, mostly Markdown
        bierner.markdown-checkbox
        hediet.vscode-drawio
        james-yu.latex-workshop
        jgclark.vscode-todo-highlight
        tomoki1207.pdf
        yzane.markdown-pdf
        yzhang.markdown-all-in-one

        # Containers
        ms-azuretools.vscode-containers
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-containers

        # Languages and toolchains
        ms-vscode.cpptools
        ms-vscode.powershell
        redhat.java
        redhat.vscode-yaml
        vscjava.vscode-gradle
        vscjava.vscode-java-debug
        vscjava.vscode-java-dependency
        vscjava.vscode-java-test
        vscjava.vscode-maven
        vscjava.vscode-spring-initializr

        # Debugging
        firefox-devtools.vscode-firefox-debug

        # Repositories
        github.vscode-github-actions
        waderyan.gitblame
      ];
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