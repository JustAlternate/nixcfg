_: {
  imports = [
    ./nginx # Web server, reverse proxy
    ./planka # selfhosted Kanban
    ./vaultwarden
    ./openwebui # My personal llm ui backed by together ai for the inference API
    ./owncloud # selhosted google drivee
    ./hauk # selfhosted google maps sharing location service
    ./mail
    # ./minecraft
    ./monitoring
    ./action-runner
    ./JustVPN
    ./traccar
  ];

}
