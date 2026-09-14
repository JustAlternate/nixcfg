{
  pkgs,
  ...
}:
{

  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  programs.hyprland = {
    enable = true;
    # pin reason: stable ships 0.55.4; unstable 0.56.2 matches what was running before and still supports legacy .conf configs
    package = pkgs.unstable.hyprland;
    portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
  };

  # The nixpkgs module does not manage the config file; provide it system-wide.
  # Hyprland picks up /etc/xdg/hypr/hyprland.conf when no user config exists.
  environment.etc."xdg/hypr/hyprland.conf".text = ''
    env = ELECTRON_OZONE_PLATFORM_HINT, auto

    cursor:enable_hyprcursor = true
    cursor:no_hardware_cursors = true

    ${builtins.readFile ./hyprland.conf}
  '';
}
