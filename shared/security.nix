{ pkgs, ... }:
{
  users = {
    defaultUserShell = pkgs.zsh;
    users.justalternate = {
      home = "/home/justalternate";
      isNormalUser = true;
      description = "justalternate";
      extraGroups = [
        "networkmanager"
        "wheel"
        "input"
        "uinput"
      ];
    };
    users.justalternate.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKSO4cOiA8s9hVyPtdhUXdshxDXXPU15qM8xE0Ixfc21"
    ];
  };

  security = {
    rtkit.enable = true;

    # For god sake pls stop asking for my passwd every 5 commands..
    sudo = {
      enable = true;
      extraConfig = ''
        justalternate ALL=(ALL) NOPASSWD: ALL
      '';
    };

    # Polkit.
    polkit.enable = true;
  };

  services.udev.packages = [ pkgs.yubikey-personalization ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
  };

  programs.ssh.startAgent = true;

  security.pam.services = {
    swaylock.u2fAuth = true;
    swaylock.yubicoAuth = true;
    swaylock.unixAuth = false;
    login.u2fAuth = true;
    # sudo.u2fAuth = true;
  };

  # services.pcscd.enable = true;

  security.pam.yubico = {
    control = "sufficient";
    enable = true;
    debug = true;
    mode = "challenge-response";
    id = [
      "25802329"
      "25440300"
    ];
  };

  programs.yubikey-touch-detector = {
    enable = true;
    unixSocket = true;
    libnotify = true;
    verbose = false;
  };

  # Lock screen when YubiKey is removed
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
