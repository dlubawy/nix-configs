{
  description = "A Nix flake based OpenTofu environment";
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
              opentofu
              terragrunt
            ];
            env = {
              shell = "zsh";
            };
          };
        }
      );
    };
}
