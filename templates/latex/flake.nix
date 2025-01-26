{
  description = "An empty Nix flake based environment";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.05";
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      pre-commit-hooks,
    }@inputs:
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
      checks = forEachSupportedSystem (
        { pkgs }:
        {
          pre-commit-check = inputs.pre-commit-hooks.lib.${pkgs.system}.run {
            src = ./.;
            hooks = {
              nixfmt-rfc-style.enable = true;
              chktex.enable = true;
            };
          };
        }
      );
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
            inherit (self.checks.${pkgs.system}.pre-commit-check) shellHook;
            buildInputs = self.checks.${pkgs.system}.pre-commit-check.enabledPackages;
            packages =
              with pkgs;
              [
                nil
                nixfmt-rfc-style
                texlivePackages.chktex
              ]
              ++ [ tex ];
            env = {
              shell = "zsh";
              NIL_PATH = "${pkgs.nil}/bin/nil";
            };
          };
        }
      );
    };
}
