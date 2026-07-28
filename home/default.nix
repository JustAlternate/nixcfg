{ pkgs, ... }:
let
  desktopInfra = import ./packages/desktop-infra.nix { inherit pkgs; };
  browsers = import ./packages/browsers.nix { inherit pkgs; };
  communication = import ./packages/communication.nix { inherit pkgs; };
  productivity = import ./packages/productivity.nix { inherit pkgs; };
  media = import ./packages/media.nix { inherit pkgs; };
  gaming = import ./packages/gaming.nix { inherit pkgs; };
in
{
  imports = [
    ./shell
    ./cli
    ./dev
    ./desktop
    ../modules/home/git.nix
    ../modules/home/ssh.nix
  ];

  home.packages = desktopInfra ++ browsers ++ communication ++ productivity ++ media ++ gaming;

  home.sessionVariables = {
    EDITOR = "nvim";
    NIX_AUTO_RUN = 1;
    # Workaround: LW 153.0 Vulkan compositing broken on Wayland/AMD —
    # white text, blank panels, unclickable UI. Fall back to XWayland.
    # Remove after upstream fix (>153.0).
    MOZ_ENABLE_WAYLAND = "0";
  };

  programs.home-manager.enable = true;
}
