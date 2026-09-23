{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = [
      (pkgs.vimUtils.buildVimPlugin {
        pname = "selenized";
        version = "0-unstable-2025-09-28";
        src = pkgs.fetchFromGitHub {
          owner = "jan-warchol";
          repo = "selenized";
          rev = "9a753d5c575c48e29eeb2be745d9571b4cec42b3";
          hash = "sha256-gS+LdNHGjai4EJXmJXORbWSY2vTxdL9w89HMR+sNldY=";
        };
        sourceRoot = "source/editors/vim";
      })
    ];
    initLua = ''
      vim.o.number = true
      vim.o.relativenumber = true
      vim.o.background = "dark"
      vim.cmd.colorscheme("selenized_bw")
    '';
  };
}
