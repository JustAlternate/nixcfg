{ pkgs, ... }: {
  programs.fastfetch = {
    package = pkgs.unstable.fastfetch;
    enable = true;
    settings = {
      logo = {
        type = "kitty-direct";
        source = "./nixos-logo.png";
        width = 32;
        height = 15;
      };

      display = {
        size.binaryPrefix = "si";
        color = "cyan";
        separator = "  ";
      };

      modules = [
        "break"
        {
          "type" = "title";
          "key" = "              ";

        }
        {
          "type" = "custom";
          "format" = "╭──────────────────────SYSTEM──────────────────────╮";
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
          "type" = "custom";
          "format" = "╰──────────────────────────────────────────────────╯";
        }
        "break"
      ];
    };
  };
}
