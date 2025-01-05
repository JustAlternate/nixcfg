# nixcfg

This repository is used to manage my systems using Nix.

- Beaver: My VPS running NixOS and selfhosting services such a kanban, a cloud storage, my websites...
- Swordfish: My desktop gaming station which I also use for intensive computation.
- Parrot: My semi gaming laptop which I mainly use for study and abroad.
- Owl: My arm processor Mac M1.
- Gecko: My raspberry py configs (WIP)

## My very pywal centric NixOS Hyprland rice

(For both swordfish and Parrot)

### Video Showcase [11 Aug 2024]

[![video showcase](https://img.youtube.com/vi/M6VRL6bqdks/0.jpg)](https://www.youtube.com/watch?v=M6VRL6bqdks)
_click the image to go to the video_

This repository contains the declaration of my system running under [NixOS](https://nixos.org/)

### Features

#### Desktop (Swordfish and Parrot)
- DE: Hyprland
- Terminal: Kitty
- Bar: Eww
- File Manager: yazi
- Editor: Neovim (LazyVim)
- Fetcher: fastfetch
- Font: nerdfonts
- Launcher: rofi-wayland
- Browser: firefox
- Discord: Vesktop
- System monitoring: mission-center, conky
- Emoji wheel: rofi + bemoji
- Music Visualizer: cava

## Installation

Enter a shell with git and vim.
```
nix-shell -p git vim
```

Clone the repository and enter it
```
git clone https://github.com/JustAlternate/nixcfg
cd nixcfg
```

Create your very own host folder
```
mkdir <myMachineName>
```

Create your hardware config
```
nixos-generate-config --show-hardware-config > <myMachineName>/hardware-config.nix
```

Modify your host configuration by importing different modules
```
vim <myMachineName>/configuration.nix
```

Modify the flake.nix to add your machine
```
vim flake.nix
```

Temporary activate flakes experimental features and rebuild switch
```
NIX_CONFIG="experimental-features = nix-command flakes"
sudo nixos-rebuild switch --flake .#<myMachineName>Nixos
```

## Advanced Install process (optional)

Create a `.ssh` folder and populate it with your ssh private key
```
mkdir -p ~/.ssh
ssh-keygen -t ed25519 -C "email@email.com"
```

Create your sops age private key
```
sudo mkdir -p /nix/sops/age
sudo nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i /home/justalternate/.ssh/id_ed25519 > /nix/sops/age/keys.txt"
```
