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
              trufflehog = {
                enable = true;
                name = "🔒 Security · Detect hardcoded secrets";
              };
              nixfmt-rfc-style = {
                enable = true;
                name = "🔍 Code Quality · ❄️ Nix · Format";
                after = [ "trufflehog" ];
              };
              ruff = {
                enable = true;
                name = "🔍 Code Quality · 🐍 Python · Fix";
                after = [ "trufflehog" ];
              };
              ruff-format = {
                enable = true;
                name = "🔍 Code Quality · 🐍 Python · Format";
                after = [ "ruff" ];
              };
              isort = {
                enable = true;
                name = "🔍 Code Quality · 🐍 Python · Import sort";
                after = [ "ruff-format" ];
              };
              flake-checker = {
                enable = true;
                name = "✅ Data & Config Validation · ❄️ Nix · Flake checker";
                args = [
                  "--check-supported"
                  "false"
                ];
                after = [
                  "nixfmt-rfc-style"
                  "ruff"
                  "ruff-format"
                  "isort"
                ];
              };
              check-yaml = {
                enable = true;
                name = "✅ Data & Config Validation · YAML · Lint";
                after = [
                  "nixfmt-rfc-style"
                  "ruff"
                  "ruff-format"
                  "isort"
                ];
              };
              mdformat = {
                enable = true;
                name = "📝 Docs · Markdown · Format";
                after = [
                  "flake-checker"
                  "check-yaml"
                ];
              };
              checkmake = {
                enable = true;
                name = "🐮 Makefile · Lint";
                after = [ "mdformat" ];
              };
              check-case-conflicts = {
                enable = true;
                name = "📁 Filesystem · Check case sensitivity";
                after = [ "checkmake" ];
              };
              check-symlinks = {
                enable = true;
                name = "📁 Filesystem · Check symlinks";
                after = [ "checkmake" ];
              };
              check-merge-conflicts = {
                enable = true;
                name = "🌳 Git Quality · Detect conflict markers";
                after = [
                  "check-symlinks"
                  "check-case-conflicts"
                ];
              };
              forbid-new-submodules = {
                enable = true;
                name = "🌳 Git Quality · Prevent submodule creation";
                after = [
                  "check-symlinks"
                  "check-case-conflicts"
                ];
              };
              no-commit-to-branch = {
                enable = true;
                name = "🌳 Git Quality · Protect main branch";
                settings.branch = [ "main" ];
                stages = [ "pre-push" ];
                after = [
                  "check-symlinks"
                  "check-case-conflicts"
                ];
              };
              check-added-large-files = {
                enable = true;
                name = "🌳 Git Quality · Block large file commits";
                args = [ "--maxkb=5000" ];
                after = [
                  "check-symlinks"
                  "check-case-conflicts"
                ];
              };
              commitizen = {
                enable = true;
                name = "🌳 Git Quality · Validate commit message";
                stages = [ "commit-msg" ];
                after = [
                  "check-symlinks"
                  "check-case-conflicts"
                ];
              };
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
                ruff
                python312
                nil
                nixfmt-rfc-style
              ]
              ++ (with pkgs.python312Packages; [
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
