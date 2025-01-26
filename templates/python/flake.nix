{
  description = "A Nix flake based Python environment";
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
              black.enable = true;
              isort.enable = true;
            };
          };
        }
      );
      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            inherit (self.checks.${pkgs.system}.pre-commit-check) shellHook;
            buildInputs = self.checks.${pkgs.system}.pre-commit-check.enabledPackages;
            venvDir = "venv";
            packages =
              with pkgs;
              [
                black
                isort
                python311
                nil
                nixfmt-rfc-style
              ]
              ++ (with pkgs.python311Packages; [
                pip
                venvShellHook
              ]);
            env = {
              shell = "zsh";
              NIL_PATH = "${pkgs.nil}/bin/nil";
            };
          };
        }
      );
    };
}
