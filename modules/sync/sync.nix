# Syncthing for folders inside ~/Projects. docs/syncthing.md has how it is set up and reached.
{ user, lib, ... }:
let
  # Ignore rules live in plain files next to this one, one pattern per line.
  readIgnore = file: lib.splitString "\n" (lib.removeSuffix "\n" (builtins.readFile file));

  # Keep replaced files around so a bad sync can be undone. Applied to every folder.
  versioning = {
    type = "simple";
    params = {
      keep = "6";
      cleanoutDays = "30";
    };
  };
in
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

      folders.cv = {
        name = "CV";
        path = "/home/${user}/Projects/Work/CV";
        id = "lqfgr-efdud";
        devices = [
          "s-mk1"
          "l-mk1"
        ];

        ignorePatterns = readIgnore ./syncthing-ignore/cv.stignore;
        inherit versioning;
      };

      # Folders must stay in sync with what s-mk1 shares; its own Syncthing declares the same ones.
      folders.obsidian = {
        name = "Obsidian";
        path = "/home/${user}/Projects/Obsidian";
        id = "npupn-wshg2";
        devices = [
          "s-mk1"
          "l-mk1"
        ];

        # .stignore itself never syncs between devices, so Nix writes it from this file.
        ignorePatterns = readIgnore ./syncthing-ignore/obsidian.stignore;
        inherit versioning;
      };

      folders.pinkytime = {
        name = "Pinky-Time";
        path = "/home/${user}/Projects/UCLL/PinkyTime";
        id = "efggw-eo6ge";
        devices = [
          "s-mk1"
          "l-mk1"
        ];

        ignorePatterns = readIgnore ./syncthing-ignore/pinkytime.stignore;
        inherit versioning;
      };
    };
  };
}