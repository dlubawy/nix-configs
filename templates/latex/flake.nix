{
  description = "An empty Nix flake based environment";
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
        let
          tex = (
            pkgs.texlive.combine {
              inherit (pkgs.texlive)
                scheme-small
                moderncv
                fontawesome5
                multirow
                arydshln
                ;
            }
          );
        in
        {
          default = pkgs.mkShell {
            packages = [ tex ];
            env = {
              shell = "zsh";
            };
          };
        }
      );
    };
}
