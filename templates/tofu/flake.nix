{
  description = "A Nix flake based OpenTofu environment";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
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
          pre-commit-check = inputs.pre-commit-hooks.lib.${pkgs.stdenv.hostPlatform.system}.run {
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
              terraform-format = {
                enable = true;
                name = "🔍 Code Quality · ◻️ OpenTofu · Format";
                after = [ "trufflehog" ];
              };
              terraform-validate = {
                enable = true;
                name = "🔍 Code Quality · ◻️ OpenTofu · Validate";
                after = [ "terraform-format" ];
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
                  "terraform-format"
                  "terraform-validate"
                ];
              };
              check-yaml = {
                enable = true;
                name = "✅ Data & Config Validation · YAML · Lint";
                after = [
                  "nixfmt-rfc-style"
                  "terraform-format"
                  "terraform-validate"
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
              just = {
                enable = true;
                name = "🤖 Justfile · Format";
                entry = "just --fmt --unstable";
                files = "^justfile$";
                pass_filenames = false;
                after = [ "mdformat" ];
              };
              check-case-conflicts = {
                enable = true;
                name = "📁 Filesystem · Check case sensitivity";
                after = [ "just" ];
              };
              check-symlinks = {
                enable = true;
                name = "📁 Filesystem · Check symlinks";
                after = [ "just" ];
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
            inherit (self.checks.${pkgs.stdenv.hostPlatform.system}.pre-commit-check) shellHook;
            buildInputs = self.checks.${pkgs.stdenv.hostPlatform.system}.pre-commit-check.enabledPackages;
            packages = with pkgs; [
              just
              opentofu
              terragrunt
              nil
              nixfmt-rfc-style
            ];
            env = {
              shell = "zsh";
              NIL_PATH = "${pkgs.nil}/bin/nil";
            };
          };
        }
      );
    };
}
