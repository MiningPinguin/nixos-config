# Syncthing: file sync between d-mk4, s-mk1 and l-mk1. The Home Manager
# module, because services.syncthing runs as its own account and cannot read
# this user's home. Everything is declared below, so nothing added in the GUI
# survives the next activation. The GUI is loopback only:
#   ssh -L 8384:127.0.0.1:8384 d-mk4
{ user, ... }:
{
  home-manager.users.${user}.services.syncthing = {
    enable = true;

    settings = {
      devices.s-mk1 = {
        id = "INS5DUQ-SKAC44P-ZEDAMIN-7CH3GOP-PAHJR75-7S5ZG2A-MPP2E6I-AYRENAQ";
      };

      devices.l-mk1 = {
        id = "JYDXLVW-SHU3IWS-HQI3JQV-HP6DYWW-DXJJSZU-EGKOTDA-UVG3PP5-XOTMXA3";
      };

      # Must be identical on every device, s-mk1 declares the same one.
      folders.projects = {
        path = "/home/${user}/Projects";
        id = "miningpinguin-projects";
        devices = [
          "s-mk1"
          "l-mk1"
        ];

        # Regenerable build output and editor droppings, no point syncing those.
        ignorePatterns = [
          "node_modules/"
          "target/"
          "dist/"
          "build/"
          "out/"
          ".next/"
          "__pycache__/"
          ".venv/"
          "*.pyc"
          "*.o"
          ".DS_Store"
          "Thumbs.db"
          "*~"
          "*.swp"
          ".gradle"
          ".idea"
          ".kotlin"
        ];

        # Keep replaced files around so a bad sync can be undone.
        versioning = {
          type = "simple";
          params.keep = "10";
        };
      };
    };
  };
}
