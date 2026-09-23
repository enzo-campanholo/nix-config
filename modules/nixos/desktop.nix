{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.niri.enable = true;
  environment.systemPackages = [ pkgs.xwayland-satellite ];

  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session.command = "${lib.getExe pkgs.tuigreet} --time --remember --cmd ${lib.getExe' config.programs.niri.package "niri-session"}";
  };

  services.logind.settings.Login.HandlePowerKey = "suspend";

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    # Java AWT assumes a reparenting window manager unless it recognises one; xwayland-satellite isn't.
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };

  # niri doesn't compose dead keys, and on Wayland GTK 4 and Chromium leave it to an input method.
  # https://niri-wm.github.io/niri/Application-Issues.html#gtk-4-dead-keys-compose
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
  };
  # fcitx5 composes with the locale's table: en_US maps dead_acute + c to ć, pt_BR to ç.
  i18n.extraLocaleSettings.LC_CTYPE = "pt_BR.UTF-8";

  networking.networkmanager.enable = true;
  networking.modemmanager.enable = false;
  users.users.isolino.extraGroups = [ "networkmanager" ];

  security.rtkit.enable = true;
  services.gvfs.enable = true;
}
