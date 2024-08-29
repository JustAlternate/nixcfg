{ pkgs, config, ... }: {
  programs.fastfetch = {
    package = pkgs.unstable.fastfetch;
    enable = true;
    settings = {
      logo = {
        padding = {
          top = 1;
          right = 1;
        };
        type = "kitty-direct";
        source = "${config.home.homeDirectory}/.config/dotfiles/Laptop/home/rice/fastfetch/nixos-logo-small.png";
      };

      display = {
        size.binaryPrefix = "si";
        color = "cyan";
        separator = "  ";
      };

      modules = [
        {
          "type" = "custom";
          "format" = "╭──────────────────────SYSTEM──────────────────────╮";
        }
        {
          "type" = "title";
          "key" = "├─ HOST";
          "keyColor" = "blue";
        }
        {
          "type" = "os";
          "key" = "├─ OS";
          "format" = "{3} ({12})";
          "keyColor" = "red";
        }
        {
          "type" = "kernel";
          "key" = "├─ KERNEL";
          "format" = "{1} {2}";
          "keyColor" = "green";
        }
        {
          "type" = "uptime";
          "key" = "├─ UPTIME";
          "keyColor" = "yellow";
        }
        {
          "type" = "packages";
          "key" = "├─ PACKAGES";
          "keyColor" = "blue";
        }
        {
          "type" = "wm";
          "key" = "├─ WINDOW MANAGER";
          "keyColor" = "red";
        }
        {
          "type" = "terminal";
          "key" = "├─ TERMINAL";
          "keyColor" = "green";
        }
        {
          "type" = "media";
          "key" = "├─󰝚 PLAYING";
          "keyColor" = "yellow";
          "format" = "{1}";
        }
        {
          "type" = "custom";
          "format" = "╰──────────────────────────────────────────────────╯";
        }
        "break"
      ];
    };
  };
}
