_: {
  imports = [
    ./nginx # Web server, reverse proxy
    ./anubis # Anti-bot challenge
    ./vaultwarden
    ./openwebui
    ./mail
    ./monitoring
    ./dawarich
    ./keycloak
    ./goatcounter
    ./gotify
    ./mail-monitor
    ./headscale
  ];
}
