{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  isolinoKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHmdvVI+bCuVV30u90N68GFXu4SY439a9wKV1SOIr7Rs isolino@MONSTRAO";
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
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
  # dhcpcd's resolvconf hook clears the link's DNS servers in resolved whenever a Router Advertisement brings none.
  networking.useNetworkd = true;
  # The router also offers itself as an IPv6 DNS server, and its replies to EDNS queries are malformed
  # (the OPT record ahead of the answer). Keep the DHCPv4 servers only.
  systemd.network.networks."99-ethernet-default-dhcp" = {
    ipv6AcceptRAConfig.UseDNS = false;
    dhcpV6Config.UseDNS = false;
  };
  services.tailscale.enable = true;
  # Without resolved, tailscaled reads the upstream DNS servers when it starts, before DHCP has provided any.
  services.resolved.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  users.users = {
    # Deploys go to root@: making isolino a trusted Nix user would let its agents become root.
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
  ++ (with llmAgents; [
    claude-code
    codex
    hermes-agent
    openclaw
    t3code
  ]);

  # `hermes gateway install` writes a unit that runs Nix's bare Python, which can't load Hermes.
  systemd.user.services.hermes = {
    description = "Hermes Agent gateway";
    wantedBy = [ "default.target" ];
    unitConfig.ConditionPathExists = "%h/.hermes/config.yaml";
    # The default PATH would hide the user's tools from the agent.
    enableDefaultPath = false;
    serviceConfig = {
      ExecStart = "${lib.getExe llmAgents.hermes-agent} gateway run";
      Restart = "on-failure";
    };
  };

  # Not t3code.service, the name `t3 service install` gives its own unit, which would override this one.
  systemd.user.services.t3 = {
    description = "T3 Code server";
    wantedBy = [ "default.target" ];
    # Deploys log in as root, whose user manager would otherwise serve T3 Code as root.
    unitConfig.ConditionUser = "!@system";
    # Restarting it kills its terminals, along with any switch being run from one.
    restartIfChanged = false;
    enableDefaultPath = false;
    serviceConfig = {
      # A port per user from their UID: 31000 for isolino, 31001 for lavietos.
      ExecStart = "${lib.getExe llmAgents.t3code} serve --host 100.92.247.56 --port 3%U";
      Restart = "on-failure";
      # At boot it starts before tailscale0 has its address, so keep retrying until it does.
      RestartSec = 5;
    };
  };

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
