# What in the config has a newer version than what is installed, as a pop-up
# on login.
#
# For a flake, "out of date" has one meaning: an input has moved on since
# flake.lock was written. Reporting package versions rather than input
# revisions means evaluating this config twice, once as locked and once with
# updates.input pinned to its upstream head, and diffing the two.
#
# Packages are read off the config rather than looked up by name, because
# nixpkgs no longer has top-level aliases for KDE Gear: pkgs.kate and
# pkgs.konsole do not exist, only kdePackages.kate and kdePackages.konsole.
# Anything added to a module later is covered without a watchlist here.
#
# The upstream dump is cached per revision, so a login only re-evaluates once
# the tracked input has actually moved.
{ config, lib, pkgs, user, ... }:
let
  inherit (lib) mkOption types;

  # Both package lists, as { n = name; v = version; }. tryEval is read through
  # .value on purpose: it catches a version that throws, but re-forcing
  # p.version afterwards throws again, and map forces it.
  dump = ''
    cfg: let
      info = p: {
        n = (let t = builtins.tryEval (p.pname or p.name); in if t.success then t.value else "?");
        v = (let t = builtins.tryEval (p.version or null); in if t.success then t.value else null);
      };
      all = ps: builtins.filter (i: i.v != null) (map info ps);
    in all cfg.environment.systemPackages ++ all cfg."home-manager".users.${user}.home.packages
  '';

  # Collapse the diff. A name can appear more than once in one snapshot (fuse
  # carries both fuse2 and fuse3), so versions are compared as sets; comparing
  # single values makes those flap on every run. Bumps that share a from and a
  # to are then folded into a single line.
  diff = ''
    def sets($rows):
      reduce $rows[] as $r ({}; .[$r.n] = ((.[$r.n] // []) + [$r.v]))
      | with_entries(.value |= unique);
    sets($old[0]) as $o
    | sets($new[0]) as $n
    | ([($o | keys[]), ($n | keys[])] | unique
      | map({ k: ., o: ($o[.] // [] | join(", ")), n: ($n[.] // [] | join(", ")) })
      | map(select(.o != .n))
      | group_by(.o + "\u0000" + .n)
      | map({ o: .[0].o, n: .[0].n, count: length, names: map(.k) })
      | sort_by(.count, .names[0]))
  '';

  outdated = pkgs.writeShellApplication {
    name = "nixos-config-outdated";
    runtimeInputs = [
      pkgs.jq
      pkgs.libnotify
      pkgs.nix
      pkgs.qt6Packages.qttools
      pkgs.systemd
    ];
    text = ''
      dir=$1
      input=$2
      host=$3

      state_root=''${XDG_STATE_HOME:-$HOME/.local/state}
      state="$state_root/nixos-config"
      mkdir -p "$state"

      # The tracked input's upstream reference, straight from the lock file, so
      # that moving the channel means editing one place.
      # shellcheck disable=SC2016
      ref=$(jq -r --arg n "$input" '
        .nodes[$n].original
        | if .url then .url
          else "\(.type):\(.owner)/\(.repo)\(.ref // "" | if . == "" then "" else "/" + . end)"
          end' "$dir/flake.lock") || exit 0
      [ -n "$ref" ] && [ "$ref" != "null" ] || exit 0

      rev=$(nix --extra-experimental-features "nix-command flakes" \
        flake metadata "$ref" --json 2>/dev/null | jq -r '.locked.rev') || exit 0
      [ -n "$rev" ] && [ "$rev" != "null" ] || exit 0

      # Plasma owns the notification server and is not up yet when
      # graphical-session.target fires.
      ready=false
      for _ in {1..10}; do
        if busctl --user --quiet call org.freedesktop.Notifications \
          /org/freedesktop/Notifications org.freedesktop.Notifications \
          GetCapabilities >/dev/null 2>&1; then
          ready=true
          break
        fi
        sleep 3
      done
      [ "$ready" = true ] || exit 0

      upstream="$state/versions-$rev.json"
      if [ ! -s "$upstream" ]; then
        # shellcheck disable=SC2016
        nix --extra-experimental-features "nix-command flakes" eval --json \
          --override-input "$input" "$ref" "path:$dir#nixosConfigurations.$host.config" \
          --apply '${dump}' > "$upstream.part" 2>/dev/null || exit 0
        [ -s "$upstream.part" ] || { rm -f "$upstream.part"; exit 0; }
        mv "$upstream.part" "$upstream"
        for stale in "$state"/versions-*.json; do
          if [ -e "$stale" ] && [ "$stale" != "$upstream" ]; then rm -f "$stale"; fi
        done
      fi

      locked="$state/locked.json"
      # shellcheck disable=SC2016
      nix --extra-experimental-features "nix-command flakes" eval --json \
        "path:$dir#nixosConfigurations.$host.config" \
        --apply '${dump}' > "$locked.part" 2>/dev/null || exit 0
      [ -s "$locked.part" ] || { rm -f "$locked.part"; exit 0; }
      mv "$locked.part" "$locked"

      # shellcheck disable=SC2016
      groups=$(jq -rn --slurpfile old "$locked" --slurpfile new "$upstream" '${diff}') || exit 0
      [ "$(jq 'length' <<< "$groups")" -gt 0 ] || { rm -f "$state/seen"; exit 0; }

      # Announce a change once, then stay quiet until the diff itself changes.
      seen=$(jq -c '[.[] | .o + " -> " + .n] | sort' <<< "$groups")
      if [ -f "$state/seen" ] && [ "$(cat "$state/seen")" = "$seen" ]; then exit 0; fi
      printf '%s\n' "$groups" > "$state/last-diff.json"

      count=$(jq '[.[].count] | add' <<< "$groups")
      # Separated by unit, not tab: tab is IFS whitespace, so read would fold
      # away an empty side and shift the columns.
      body=$(jq -r '
        .[] | [(if .count == 1 then .names[0] else "\(.count) packages" end),
               (if .o == "" then "new" else .o end),
               (if .n == "" then "dropped" else .n end)]
        | join("\u001f")' <<< "$groups" |
        while IFS=$'\x1f' read -r label from to; do
          printf '  %-18s %-22s ->  %s\n' "$label" "$from" "$to"
        done)

      rebuild="nix flake update && sudo nixos-rebuild switch --flake .#$host"

      # --action implies --wait, so this blocks until the toast is clicked or
      # expires. Klipper is the clipboard under Wayland, where wl-copy has no
      # display to talk to. A dismissal still counts as told: only a newer diff
      # should speak up again, not the next login.
      choice=$(notify-send --app-name=nixos-config --expire-time=30000 \
        --action=copy="Copy update command" \
        "nixos-config: $count packages have newer versions" "$body") || choice=""
      if [ "$choice" = copy ]; then
        qdbus org.kde.klipper /klipper \
          org.kde.klipper.klipper.setClipboardContents "$rebuild"
      fi

      printf '%s\n' "$seen" > "$state/seen"
    '';
  };
in
{
  options.updates = {
    configDir = mkOption {
      type = types.str;
      default = "/home/${user}/nixos-config";
      description = "Where the flake lives, so the check can re-evaluate it.";
    };

    input = mkOption {
      type = types.str;
      default = "nixpkgs-unstable";
      description = ''
        The flake input whose upstream head is compared against the lock.
        Hosts on the stable channel track "nixpkgs" instead.
      '';
    };
  };

  config = {
    systemd.user.services.nixos-config-updates = {
      description = "Report packages with newer versions than the ones installed";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      unitConfig.ConditionPathExists = "${config.updates.configDir}/flake.nix";
      serviceConfig.Type = "exec";
      serviceConfig.ExecStart = lib.escapeShellArgs [
        (lib.getExe outdated)
        config.updates.configDir
        config.updates.input
        config.networking.hostName
      ];
    };
  };
}
