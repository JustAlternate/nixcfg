# Open WebUI Computer (cptr) — packaged from the upstream PyPI wheel.
#
# To bump: update `version` + `hash` below. The wheel bundles the built
# SvelteKit frontend, so no Node build is needed.
#
#   nix hash file <downloaded .whl>   # → sha256-...
#
# Latest release: https://github.com/open-webui/computer/releases
{
  lib,
  python3,
  fetchurl,
}:
let
  version = "0.9.21";
  sha256 = "sha256-J5AzSijym8HttPT4GyqEmGOQWb9OyULnV4CxDAxrTRg=";
  py = python3;
in
py.pkgs.buildPythonApplication rec {
  pname = "cptr";
  inherit version;

  format = "wheel";
  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/26/af/358111f4fd95c946e708bc4d5e6b38316eee8af3145ca35d74eb97c66898/cptr-${version}-py3-none-any.whl";
    inherit sha256;
  };

  propagatedBuildInputs = with py.pkgs; [
    aiosqlite
    alembic
    bcrypt
    click
    cryptography
    fastapi
    httpx
    loguru
    pyjwt
    python-dateutil
    python-socketio
    sqlalchemy
    truststore
    uvicorn
    watchdog
    # fastapi[standard] extras pulled in at runtime:
    aiohttp
    greenlet
    jinja2
    python-multipart
    email-validator
    pyyaml
    websockets
  ];

  # Wheel ships its own SvelteKit build; nothing to compile.
  dontBuild = true;

  doCheck = false;

  meta = with lib; {
    description = "Open WebUI Computer — your whole machine in a browser";
    homepage = "https://github.com/open-webui/computer";
    license = licenses.elastic20;
    mainProgram = "cptr";
  };
}
