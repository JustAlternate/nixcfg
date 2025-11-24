{
  lib,
  pkgs,
  ...
}:

with lib;

{
  networking.nat = {
    enable = true;
    externalInterface = "eth0";
    internalInterfaces = [ "wg0" ];
  };

  networking.firewall.allowedUDPPorts = mkAppend [ 51820 ];

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];
    listenPort = 51820;

    # Safely reference iptables via pkgs (passed as module input)
    postSetup = ''
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
    '';
    postShutdown = ''
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
    '';

    privateKeyFile = "/var/lib/wireguard/server-private.key";

    peers = [
      {
        publicKey = "eflQBd5B3sxuAFYBH2/k2aw3v8Gv8O17/LxdsDLa1AM=";
        allowedIPs = [ "10.100.0.2/32" ];
      }
    ];
  };
}
