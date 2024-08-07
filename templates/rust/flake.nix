{
  description = "A Nix flake based Rust environment";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-24.05";

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f: nixpkgs.lib.genAttrs supportedSystems (system: f { pkgs = import nixpkgs { inherit system; }; });
    in
    {
      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              (with rustPlatform; [
                cargo
                rustc
                rustLibSrc
              ])
              clippy
              rustfmt
            ];
            env = {
              RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
              shell = "zsh";
            };
          };
        }
      );
    };
}
