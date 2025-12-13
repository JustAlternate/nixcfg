{ lib, inputs, ... }: {

  imports = [
    inputs.hyprland.nixosModules.default
  ];

  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  programs = {
    hyprland = {
      enable = true;
      settings = {
        env = lib.mkMerge [
          "ELECTRON_OZONE_PLATFORM_HINT, auto"
        ];
        cursor = {
          enable_hyprcursor = true;
          no_hardware_cursors = true;
        };
      };
      extraConfig = lib.mkMerge ''
        ${builtins.readFile ../shared/desktop/hyprland/hyprland.conf}
      '';
    };

		zsh.profileExtra = ''
			[[ $(tty) == /dev/tty1 ]] && exec Hyprland
		'';

	}
}
