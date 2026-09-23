{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gcc
    gdb
    clang-tools
    gnumake
    cmake
    nixd
    nixfmt
  ];
  programs.java = {
    enable = true;
    package = pkgs.jdk25;
  };
}
