{ inputs, pkgs, ... }:
{
  imports = [ inputs.nix-index-database.homeModules.default ];

  home = {
    stateVersion = "26.05";
    packages =
      (with pkgs; [
        ripgrep
        fd
        jq
      ])
      ++ (with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
        claude-code
        codex
        pi
      ]);
  };

  programs = {
    bash.enable = true;
    fish = {
      enable = true;
      interactiveShellInit = "set -g fish_greeting";
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    nix-index-database.comma.enable = true;
    gh.enable = true;
    git = {
      enable = true;
      settings = {
        user = {
          name = "Enzo L. Campanholo";
          email = "199099542+enzo-campanholo@users.noreply.github.com";
        };
        init.defaultBranch = "main";
      };
    };
  };
}
