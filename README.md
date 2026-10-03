# nix-config

NixOS and Home Manager configuration for my machines: MONSTRAO, a desktop, and MONSTRINHO, a headless home server on a laptop.

## Rebuild

```sh
nh os switch        # or: sudo nixos-rebuild switch --flake ~/nix-config
```

A daily GitHub Action updates `flake.lock` once the checks and both builds pass. MONSTRAO then installs that commit for the next boot, and MONSTRINHO switches to it at 04:40, or, if the kernel or initrd changed, reboots into it between 04:00 and 06:00 and otherwise leaves it for the next boot. Either way it replaces anything switched to locally, so push local changes.

## Tailscale

Both machines enable Tailscale and systemd-resolved in the common module. After rebuilding MONSTRAO, run `sudo tailscale up` and follow its login URL to join the same tailnet as MONSTRINHO. The login is stored in `/var/lib/tailscale` and survives rebuilds and reboots.

```sh
sudo tailscale up
tailscale ping MONSTRINHO
```

## Recovery

- Run `sudo nixos-rebuild switch --rollback`; if a machine doesn't boot, pick an older generation in its boot menu first. Then revert or fix the bad commit on GitHub: MONSTRAO installs `main` at every boot and MONSTRINHO every night, and stopping `nixos-upgrade.timer` only lasts until the next reboot.
- MONSTRAO's Secure Boot keys live in `/var/lib/sbctl`. Back them up. If they are lost, nothing new will boot until Secure Boot is turned off or new keys are enrolled.
- MONSTRAO's 1 GiB EFI partition is shared with Windows. Never delete `EFI/Microsoft`. The boot menu keeps 5 generations so the partition does not fill up.
