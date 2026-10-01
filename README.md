# nix-config

NixOS and Home Manager configuration for my machines: MONSTRAO, a desktop, and MONSTRINHO, a headless home server on a laptop.

## Rebuild

```sh
nh os switch        # or: sudo nixos-rebuild switch --flake ~/nix-config
```

A daily GitHub Action updates `flake.lock` once the checks and both builds pass. MONSTRAO then installs that commit for the next boot, and MONSTRINHO switches to it, rebooting before 06:00 if the kernel changed. Either way it replaces anything switched to locally, so push local changes.

## Recovery

- Pick an older generation in the boot menu and run `sudo nixos-rebuild switch --rollback` to make it the default. Then revert or fix the bad commit on GitHub: MONSTRAO installs `main` at every boot and MONSTRINHO every night, and stopping `nixos-upgrade.timer` only lasts until the next reboot.
- MONSTRAO's Secure Boot keys live in `/var/lib/sbctl`. Back them up. If they are lost, nothing new will boot until Secure Boot is turned off or new keys are enrolled.
- MONSTRAO's 1 GiB EFI partition is shared with Windows. Never delete `EFI/Microsoft`. The boot menu keeps 5 generations so the partition does not fill up.
