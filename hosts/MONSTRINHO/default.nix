{ inputs, pkgs, ... }:
let
  isolinoKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHmdvVI+bCuVV30u90N68GFXu4SY439a9wKV1SOIr7Rs isolino@MONSTRAO";
in
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    inputs.disko.nixosModules.disko
    ../../modules/nixos/common.nix
  ];

  networking.hostName = "MONSTRINHO";

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ "consoleblank=60" ];
  };

  services.logind.settings.Login.HandleLidSwitch = "ignore";
  systemd.sleep.settings.Sleep = {
    AllowSuspend = false;
    AllowHibernation = false;
  };
  services.upower = {
    enable = true;
    criticalPowerAction = "PowerOff";
  };
  # Without a desktop nothing activates upower over D-Bus, so it would never see the battery run down.
  systemd.services.upower.wantedBy = [ "multi-user.target" ];
  services.thermald.enable = true;
  # This firmware has no usable adaptive policy: thermald exits and expects a restart to run without one, as upstream's unit does.
  systemd.services.thermald.serviceConfig.Restart = "on-failure";
  zramSwap.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  users.users = {
    # Passwords stay out of the repository: root sets isolino's after the install.
    root.openssh.authorizedKeys.keys = [ isolinoKey ];
    isolino = {
      openssh.authorizedKeys.keys = [ isolinoKey ];
      linger = true;
    };
    # No wheel: lavietos's agents run as lavietos, and sudo would give them the whole machine.
    lavietos = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJU9VqlHeLAvukPFLKW8vN4BedMxQBasFvn6JYD4NCZe luis@DESKTOP-I16FQN7"
      ];
      linger = true;
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv/isolino 0700 isolino users"
    "d /srv/lavietos 0700 lavietos users"
    "d /srv/shared 2770 root users"
    # Keeps files in the shared directory writable by both of us whatever the creator's umask.
    "a+ /srv/shared - - - - default:group::rwx"
  ];

  programs.git.enable = true;
  environment.systemPackages = [
    # Ghostty on MONSTRAO sends TERM=xterm-ghostty over SSH.
    pkgs.ghostty.terminfo
  ]
  ++ (with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    claude-code
    codex
    hermes-agent
    openclaw
    t3code
  ]);

  system.autoUpgrade = {
    enable = true;
    flake = "github:enzo-campanholo/nix-config#MONSTRINHO";
    upgrade = false;
    allowReboot = true;
    rebootWindow = {
      lower = "04:00";
      upper = "06:00";
    };
  };

  home-manager.users.isolino.imports = [
    ../../home/common.nix
    ../../home/neovim.nix
  ];

  system.stateVersion = "26.05";
}
