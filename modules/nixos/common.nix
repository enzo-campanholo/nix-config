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
