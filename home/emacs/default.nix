{ config, pkgs, ... }:
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    extraPackages =
      epkgs: with epkgs; [
        solarized-theme
        evil
        evil-collection
        envrc
        proof-general
        tuareg
        clojure-mode
        cider
        web-mode
        nix-mode
        (treesit-grammars.with-grammars (g: [
          g.tree-sitter-typescript
          g.tree-sitter-tsx
        ]))
        (trivialBuild {
          pname = "sail-mode";
          inherit (pkgs.ocamlPackages.sail) version src;
          sourceRoot = "sail-${pkgs.ocamlPackages.sail.version}/editors";
        })
      ];
  };

  home.file.".emacs.d/init.el".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/emacs/init.el";
}
