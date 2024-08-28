# Nix POC

## Docker vs Nix

Docker is repeatable, not reproducible.

One docker build will have different output depending when it was done.

Because of:
```
apt update
apt upgrade

# ^ useless, dangerous and ressource consuming (not great for CI pipeline)

apt install nginx
```

Nix is reproducible, if it works on my machine, it works on everyone's machine (modulo processor architecture)

```
{ pkgs ? import <nixpkgs> {} }:

pkgs.nginx.overrideAttrs (old: {
  version = "1.21.6";  # Replace with your desired version
  src = pkgs.fetchFromGitHub {
    owner = "nginx";
    repo = "nginx";
    rev = "release-1.21.6";  # Replace with the appropriate commit or tag
    sha256 = "<hash>";  # Replace with the actual hash for the version
  };
})
```
