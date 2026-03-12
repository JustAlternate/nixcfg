# Gecko Hosts Configuration

This directory contains NixOS configurations for Raspberry Pi devices (gecko hosts).

## Overview

The `gecko` hosts are Raspberry Pi-based systems running NixOS. This directory includes:

- **geckoNixos1-4**: Individual Raspberry Pi configurations
- **geckoNixosRPI3-sd-image.nix**: SD image builder for Raspberry Pi 3 B+ devices
- **hardware-pi3b+.nix**: Hardware configuration for Raspberry Pi 3 B+
- **hardware-pi4.nix**: Hardware configuration for Raspberry Pi 4
- **default.nix**: Shared base configuration for all gecko hosts

## Building an SD Image

To build an SD image for Raspberry Pi 3 B+ devices:

```bash
cd ~/nixcfg
nix build .#nixosConfigurations.geckoNixosRPI3SdImage.config.system.build.sdImage
```

The build will create a compressed image file in the `result/` directory.

## Flashing the Image

After building, you can flash the image to an SD card using `dd`:

```bash
# Flash to SD card (replace /dev/sdX with your SD card device)
sudo dd if=result/sd-image/geckoNixosRPI3-sd-image.img of=/dev/sdX bs=4M status=progress
```

## Maintenance

To update an existing system:

```bash
sudo nixos-rebuild switch --flake .#geckoNixos<number>
```

Replace `<number>` with the appropriate host number (1-4).
