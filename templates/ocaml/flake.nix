{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-darwin"
      ];
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          # opam owns the compiler and OCaml libraries; Nix only provides native dependencies.
          default = pkgs.mkShell {
            packages = with pkgs; [
              opam
              pkg-config
              m4
              gmp
            ];
            # Otherwise opam tries to nix-build the depexts that this shell already provides.
            env.OPAMASSUMEDEPEXTS = "1";
          };
        }
      );
    };
}
