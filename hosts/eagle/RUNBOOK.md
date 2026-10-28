# eagle — FIDO2 LUKS Unlock (YubiKey touch)

TUXEDO InfinityBook Pro 14 Gen10 AMD, `nvme0n1p2` LUKS2 (`46c64a55-12ec-4dca-a2cb-9be9687559ee`), YubiKey 5C NFC.

Nix config declares **how** to unlock (`boot.initrd.systemd.enable` + `fido2-device=auto`), but **enrollment is imperative** — the FIDO2 credential lives in the LUKS2 header, not in the Nix store.

## Current policy

- `user-presence = yes` (touch required, LED blinks)
- `client-pin = no` (no PIN, tap only)
- `user-verification = no` (no biometric). For YubiKey Bio, re-enroll with `=yes` (see below).

Nix: `hosts/eagle/system/default.nix` sets `crypttabExtraOpts = ["fido2-device=auto" "token-timeout=30"]`. Initrd is systemd-stage1, so fallback to passphrase after 30s if no key present.

## First enrollment (already done, documented for rebuild)

```bash
# ensure FIDO2 visible
systemd-cryptenroll --fido2-device=list   # should show /dev/hidraw2 YubiKey

# enroll touch-only (will prompt for existing LUKS passphrase, then blink -> touch)
sudo systemd-cryptenroll --fido2-device=auto \
  --fido2-with-client-pin=no \
  --fido2-with-user-presence=yes \
  --fido2-with-user-verification=no \
  /dev/disk/by-uuid/46c64a55-12ec-4dca-a2cb-9be9687559ee

# verify
sudo cryptsetup luksDump /dev/disk/by-uuid/46c64a55-12ec-4dca-a2cb-9be9687559ee | grep -E "Token|Keyslot"
sudo systemd-cryptenroll /dev/disk/by-uuid/46c64a55-12ec-4dca-a2cb-9be9687559ee
sudo cryptsetup token export /dev/disk/by-uuid/46c64a55-12ec-4dca-a2cb-9be9687559ee --token-id 0
# expect: fido2-clientPin-required:false, fido2-up-required:true, fido2-uv-required:false
```

Keep slot 0 `password` as fallback until reboot verified.

## Why `systemd-cryptsetup attach test-luks` fails on live system

`test-luks` tries to `open` the same physical device that is already active as `/` (`/dev/mapper/luks-...`). Kernel refuses with `which is in use (already mapped or mounted)`. **But** the fact it prints `Please confirm presence on security token to unlock.` *proves* the FIDO2 token is wired correctly — `systemd-cryptsetup` found the token. You cannot `test-passphrase` a mounted root with `cryptsetup open` either (same busy check). Real test is reboot, or use a detached header:

```bash
# detached-header test (no reboot)
sudo cryptsetup luksHeaderBackup /dev/disk/by-uuid/46c64a55-12ec-4dca-a2cb-9be9687559ee --header-backup-file /tmp/hdr.img
# create 16M loop file, attach header file as loop with offset? Simpler: just reboot.
# If you really need loop test, ask — we can script a loop + dm device
```

## Adding a second YubiKey

Plug only the new key, rerun the same enroll command (creates new keyslot + token). Keep old key enrolled.

## Switching to YubiKey Bio (future)

```bash
sudo systemd-cryptenroll --wipe-slot=fido2 --fido2-device=auto \
  --fido2-with-client-pin=no --fido2-with-user-presence=yes --fido2-with-user-verification=yes \
  /dev/disk/by-uuid/46c64a55-12ec-4dca-a2cb-9be9687559ee
# then
sudo systemd-cryptenroll --fido2-device=auto \
  --fido2-with-client-pin=no --fido2-with-user-presence=yes --fido2-with-user-verification=yes \
  /dev/disk/by-uuid/46c64a55-12ec-4dca-a2cb-9be9687559ee  # second Bio key if needed
```

On Bio, `uv` = fingerprint. You can also set `client-pin=yes` if you want PIN + fingerprint.

## Removing password fallback (optional, after verified)

```bash
sudo systemd-cryptenroll --wipe-slot=0 /dev/disk/by-uuid/46c64a55-12ec-4dca-a2cb-9be9687559ee
# or: sudo cryptsetup luksKillSlot /dev/disk/by-uuid/46c64a55-12ec-4dca-a2cb-9be9687559ee 0
```

Keep at least one recovery method (second YubiKey or printed recovery key). To add recovery key: `sudo systemd-cryptenroll --recovery-key /dev/disk/by-uuid/46c64a55-12ec-4dca-a2cb-9be9687559ee`

## Rebuild / recovery

```bash
# after editing hosts/eagle/system/default.nix
nixfmt hosts/eagle/system/default.nix -c
nix flake check
sudo nixos-rebuild dry-activate --flake .#eagleNixos
sudo nixos-rebuild switch --flake .#eagleNixos
```

### Cachix push

`CACHIX_AUTH_TOKEN` is shared by all desktop hosts via `secrets/secrets.yaml`. Rotate it with `sops secrets/secrets.yaml`, then switch once so `/run/secrets/cachix-env` is re-rendered.

After that, use the `rebuild` wrapper instead of `nixos-rebuild`. It runs the rebuild as root under `cachix watch-exec`, which pushes every path built locally (substituted paths are skipped):

```bash
rebuild              # switch
rebuild dry-activate
rebuild boot
```

If boot fails: systemd will fall back to passphrase prompt after 30s. Enter slot 0 password. If header corrupted, restore from backup: `sudo cryptsetup luksHeaderRestore /dev/disk/by-uuid/46c64a55-12ec-4dca-a2cb-9be9687559ee --header-backup-file /path/to/backup`

## Troubleshooting

- No prompt at boot, only password: check `boot.initrd.systemd.enable = true` and `crypttabExtraOpts` contains `fido2-device=auto`. Rebuild + check `lsinitrd | grep fido2` vs `bootctl status`.
- LED doesn't blink: `systemd-cryptenroll --fido2-device=list` empty → check `usbhid` in initrd, BIOS USB, or try `fido2-device=/dev/hidraw2` explicitly.
- Plymouth hides `Please confirm presence...` message: disable `boot.plymouth.enable` or watch YubiKey LED.
