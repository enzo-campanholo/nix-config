# nix-config

NixOS and Home Manager configuration for my machines. Currently only MONSTRAO, a desktop.

## Rebuild

```sh
nh os switch        # or: sudo nixos-rebuild switch --flake ~/nix-config#MONSTRAO
```

A daily GitHub Action updates `flake.lock` once the checks and the MONSTRAO build pass. MONSTRAO then installs that commit for the next boot, replacing anything switched to locally, so push local changes.

## Recovery

- Pick an older generation in the boot menu and run `sudo nixos-rebuild switch --rollback` to make it the default. Then revert or fix the bad commit on GitHub: MONSTRAO installs `main` at every boot, and stopping `nixos-upgrade.timer` only lasts until the next reboot.
- The Secure Boot keys live in `/var/lib/sbctl`. Back them up. If they are lost, nothing new will boot until Secure Boot is turned off or new keys are enrolled.
- The 1 GiB EFI partition is shared with Windows. Never delete `EFI/Microsoft`. The boot menu keeps 5 generations so the partition does not fill up.
