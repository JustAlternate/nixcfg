{ pkgs, ... }:
let
  # Switches the internal panel refresh rate between the plugged-in and
  # portable profile. Invoked by the shared `startup` script if present, and
  # driven by power_supply udev events. No-op on machines without a battery.
  power_profile = pkgs.writeShellScriptBin "power_profile" ''
    set -euo pipefail

    ls /sys/class/power_supply/BAT* >/dev/null 2>&1 || exit 0

    # single instance
    exec 9>''${XDG_RUNTIME_DIR:-/tmp}/eagle-power-profile.lock
    flock -n 9 || exit 0

    MON=eDP-1
    NATIVE_W=2880
    NATIVE_H=1800
    RR_AC=120
    RR_BAT=60

    ac_online() {
      local f
      for f in /sys/class/power_supply/AC*/online /sys/class/power_supply/ADP*/online; do
        [ -r "$f" ] || continue
        [ "$(cat "$f")" = "1" ] && return 0
      done
      return 1
    }

    apply() {
      hyprctl monitors -j | ${pkgs.jq}/bin/jq -e --arg m "$MON" 'any(.[]; .name == $m)' >/dev/null || return 0

      local pos scale rr
      pos=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r --arg m "$MON" '.[]|select(.name==$m)|"\(.x)x\(.y)"')
      scale=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r --arg m "$MON" '.[]|select(.name==$m)|.scale')

      if ac_online; then
        rr=$RR_AC
      else
        rr=$RR_BAT
      fi

      hyprctl keyword monitor "$MON,''${NATIVE_W}x''${NATIVE_H}@''${rr},''${pos},''${scale},vrr,2,bitdepth,10,cm,srgb"
    }

    apply
    udevadm monitor --udev --subsystem-match=power_supply --property 2>/dev/null \
      | while read -r line; do
          case "$line" in
            POWER_SUPPLY_ONLINE=*) apply ;;
          esac
        done
  '';
in
{
  imports = [
    ../../../home
  ];

  zsh.hyprlandAutostart.enable = true;

  home = {
    sessionPath = [
      "$HOME/go/bin"
    ];

    stateVersion = "26.05";

    packages = with pkgs; [
      upower
      brightnessctl
      pwvucontrol
      opentabletdriver
      power_profile
    ];
  };
}
