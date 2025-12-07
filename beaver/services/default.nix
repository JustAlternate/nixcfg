_: {
  imports = [
    ./nginx # Web server, reverse proxy
    ./planka # selfhosted Kanban
    ./vaultwarden
    # ./wireguard
    ./openwebui # My personal llm ui
    ./mail
    ./monitoring
    ./dawarich
  ];
}
