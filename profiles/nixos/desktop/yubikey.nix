{ pkgs, ... }:
{
  security = {
    rtkit.enable = true;

    pam = {
      services.swaylock = {
        u2fAuth = true;
        yubicoAuth = true;
        unixAuth = false;
      };
      services.login.u2fAuth = true;

      yubico = {
        control = "sufficient";
        enable = true;
        debug = true;
        mode = "challenge-response";
        id = [
          "25802329"
          "25440300"
        ];
      };
    };
  };

  services.udev.packages = [ pkgs.yubikey-personalization ];

  programs.yubikey-touch-detector = {
    enable = true;
    unixSocket = true;
    libnotify = true;
    verbose = false;
  };

  services.udev.extraRules = ''
    ACTION=="remove", ENV{ID_VENDOR_ID}=="1050", RUN+="${pkgs.systemd}/bin/systemctl --user --machine=justalternate@.host start swaylock-on-yubikey-remove.service"
  '';

  systemd.user.services.swaylock-on-yubikey-remove = {
    description = "Lock screen when YubiKey is removed";
    serviceConfig = {
      Type = "simple";
      ExecStart = pkgs.writeShellScript "lock-wrapper" ''
        ${pkgs.coreutils}/bin/sleep 0.5

        if ${pkgs.procps}/bin/pgrep -x swaylock > /dev/null; then
          exit 0
        fi

        exec ${pkgs.swaylock}/bin/swaylock --config /home/justalternate/.config/swaylock/config
      '';
      Environment = [
        "PATH=${pkgs.swaylock}/bin"
      ];
    };
  };
}
