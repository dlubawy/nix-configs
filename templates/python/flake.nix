{
  description = "A Nix flake based Python environment";
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
            venvDir = "venv";
            packages =
              with pkgs;
              [
                black
                isort
                python311
              ]
              ++ (with pkgs.python311Packages; [
                pip
                venvShellHook
              ]);
            shellHook = ''
              export shell=zsh
            '';
          };
        }
      );
    };
}
