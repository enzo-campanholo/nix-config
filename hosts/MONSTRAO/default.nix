{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.lanzaboote.nixosModules.lanzaboote
    ../../modules/nixos/common.nix
    ../../modules/nixos/desktop.nix
  ];

  networking.hostName = "MONSTRAO";
  time.timeZone = "America/Sao_Paulo";

  boot = {
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      # The 1 GiB ESP is shared with Windows.
      configurationLimit = 5;
    };
    kernelModules = [ "nct6775" ];
  };
  environment.systemPackages = [ pkgs.sbctl ];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    # Blackwell is only supported by the open kernel modules.
    open = true;
    powerManagement.enable = true;
  };
  nixpkgs.config.allowUnfreePackages = [
    "nvidia-x11"
    "nvidia-settings"
    "yEd"
  ];

  # The driver keeps freed buffers instead of returning them, so niri grows to ~1 GiB of VRAM.
  # https://github.com/NVIDIA/egl-wayland/issues/126#issuecomment-2379945259
  # Drop this once the driver's own nvidia-application-profiles-rc has a rule for niri.
  environment.etc."nvidia/nvidia-application-profiles-rc.d/50-niri.json".text = builtins.toJSON {
    rules = [
      {
        pattern = {
          feature = "procname";
          matches = "niri";
        };
        profile = "Limit Free Buffer Pool On Wayland Compositors";
      }
    ];
    profiles = [
      {
        name = "Limit Free Buffer Pool On Wayland Compositors";
        settings = [
          {
            key = "GLVidHeapReuseRatio";
            value = 0;
          }
        ];
      }
    ];
  };

  # The Logitech receiver wakes the machine from S3 a few seconds after every suspend
  # (/sys/power/pm_wakeup_irq and its wakeup counters); the keyboard and power button still wake it.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c547", ATTR{power/wakeup}="disabled"
  '';

  programs.coolercontrol.enable = true;
  services.fwupd.enable = true;

  system.autoUpgrade = {
    enable = true;
    flake = "github:enzo-campanholo/nix-config#MONSTRAO";
    upgrade = false;
    # Never load a new NVIDIA driver under a running session.
    operation = "boot";
  };

  home-manager.users.isolino =
    { config, ... }:
    {
      imports = [
        ../../home/common.nix
        ../../home/dev.nix
        ../../home/emacs
        ../../home/neovim.nix
        ../../home/linux/desktop.nix
        ../../home/linux/session.nix
      ];
      xdg.configFile."niri/host.kdl".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/hosts/MONSTRAO/niri.kdl";
    };

  system.stateVersion = "26.05";
}
