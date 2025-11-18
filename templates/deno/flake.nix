{
  description = "A Nix flake based Node environment";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
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
              denofmt = {
                enable = true;
                name = "🔍 Code Quality · 🦕 Deno · Format";
                after = [ "trufflehog" ];
              };
              denolint = {
                enable = true;
                name = "🔍 Code Quality · 🦕 Deno · Lint";
                after = [ "denofmt" ];
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
                  "denolint"
                ];
              };
              check-yaml = {
                enable = true;
                name = "✅ Data & Config Validation · YAML · Lint";
                after = [
                  "nixfmt-rfc-style"
                  "denolint"
                ];
              };
              prettier = {
                enable = true;
                name = "📝 Docs · All · Prettier";
                after = [
                  "flake-checker"
                  "check-yaml"
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
              check-case-conflicts = {
                enable = true;
                name = "📁 Filesystem · Check case sensitivity";
                after = [
                  "mdformat"
                  "prettier"
                ];
              };
              check-symlinks = {
                enable = true;
                name = "📁 Filesystem · Check symlinks";
                after = [
                  "mdformat"
                  "prettier"
                ];
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

      packages = forEachSupportedSystem (
        { pkgs }:
        let
          denoBin = "${pkgs.deno}/bin/deno";
        in
        {
          default = pkgs.stdenv.mkDerivation rec {
            pname = "template";
            version = "0.1.0";
            src = ./.;

            buildInputs = with pkgs; [
              deno
            ];
            nativeBuildInputs = buildInputs;

            buildPhase = ''
              DENO_DIR="$(mktemp -d)"
              DENO_INSTALL_DIR="$DENO_DIR"/bin
              mkdir -p "$DENO_INSTALL_DIR"

              env DENO_DIR="$DENO_DIR" DENO_INSTALL_DIR="$DENO_INSTALL_DIR" ${denoBin} install
              env DENO_DIR="$DENO_DIR" DENO_INSTALL_DIR="$DENO_INSTALL_DIR" ${denoBin} task build
              rm -rf "$DENO_DIR"

              mkdir -p "$out"/lib
              cp -a . "$out"/lib
            '';
            installPhase = ''
              mkdir -p "$out"/bin
              exe="$out"/bin/${pname}
              touch "$exe"
              chmod +x "$exe"
              cat > "$exe" << EOF
              #!/usr/bin/env bash
              runtime="\$(mktemp -d)"
              cp "$out"/lib/vite.config.* "\$runtime"
              cp -R "$out"/lib/node_modules "\$runtime"/node_modules
              chmod -R u+rwX,go+rX,go-w "\$runtime"/*

              cd "$out"/lib
              ${denoBin} task preview -c "\$runtime"/vite.config.*
              rm "\$runtime"/vite.config.*
              rm -rf "\$runtime"/node_modules
              rm -rf "\$runtime"
              EOF
            '';
          };
        }
      );

      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            inherit (self.checks.${pkgs.system}.pre-commit-check) shellHook;
            buildInputs =
              with pkgs;
              [
                deno
              ]
              ++ self.checks.${pkgs.system}.pre-commit-check.enabledPackages;
            packages = with pkgs; [
              (writeScriptBin "create-vite" ''
                ${pkgs.deno}/bin/deno run -A npm:create-vite .
              '')
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
