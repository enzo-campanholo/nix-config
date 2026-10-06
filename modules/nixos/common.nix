{ inputs, ... }:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  nix = {
    channel.enable = false;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      extra-substituters = [ "https://cache.numtide.com" ];
      extra-trusted-public-keys = [
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };
    optimise.automatic = true;
  };
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Otherwise anyone at the boot menu can add init=/bin/sh to the kernel command line.
  boot.loader.systemd-boot.editor = false;

  time.timeZone = "America/Sao_Paulo";

  services.fwupd.enable = true;

  services.tailscale.enable = true;
  # Without resolved, tailscaled reads the upstream DNS servers when it starts, before DHCP has provided any.
  services.resolved.enable = true;

  programs.fish.enable = true;

  programs.nh = {
    enable = true;
    flake = "/home/isolino/nix-config";
    clean = {
      enable = true;
      extraArgs = "--keep 5 --no-direnv";
    };
  };

  users.users.isolino = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
  };
}
