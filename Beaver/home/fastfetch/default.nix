{ pkgs, ... }: {
  programs.fastfetch = {
    package = pkgs.fastfetch;
    enable = true;
    settings = {
      logo = {
        source = "nixos_small";
        padding = {
          right = 1;
        };
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
          "format" = "{1} {2}";
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
