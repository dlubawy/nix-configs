{
  description = "A Nix flake based Node environment";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    git-hooks = {
      url = "github:cachix/git-hooks.nix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      git-hooks,
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
          pre-commit-check = inputs.git-hooks.lib.${pkgs.stdenv.hostPlatform.system}.run {
            src = builtins.path {
              path = ./.;
              name = "template";
            };
            package = pkgs.prek;
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
              just =
                let
                  package = pkgs.just;
                in
                {
                  enable = true;
                  package = package;
                  name = "🤖 Justfile · Format";
                  entry = "${package}/bin/just --fmt --unstable";
                  files = "^justfile$";
                  pass_filenames = false;
                  after = [
                    "mdformat"
                    "prettier"
                  ];
                };
              check-case-conflicts = {
                enable = true;
                name = "📁 Filesystem · Check case sensitivity";
                after = [
                  "mdformat"
                  "prettier"
                  "just"
                ];
              };
              check-symlinks = {
                enable = true;
                name = "📁 Filesystem · Check symlinks";
                after = [
                  "mdformat"
                  "prettier"
                  "just"
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
        {
          default =
            let
              package = {
                pname = "template";
                version = "0.1.0";
                src = builtins.path {
                  path = ./.;
                  name = "template";
                };

                buildInputs = builtins.attrValues {
                  inherit (pkgs)
                    deno
                    ;
                };
                nativeBuildInputs = package.buildInputs;

                buildPhase = ''
                  DENO_DIR="$(mktemp -d)"
                  DENO_INSTALL_DIR="$DENO_DIR"/bin
                  mkdir -p "$DENO_INSTALL_DIR"

                  env DENO_DIR="$DENO_DIR" DENO_INSTALL_DIR="$DENO_INSTALL_DIR" deno install
                  env DENO_DIR="$DENO_DIR" DENO_INSTALL_DIR="$DENO_INSTALL_DIR" deno task build
                  rm -rf "$DENO_DIR"

                  mkdir -p "$out"/lib
                  cp -a . "$out"/lib
                '';
                installPhase = ''
                  mkdir -p "$out"/bin
                  exe="$out"/bin/${package.pname}
                  touch "$exe"
                  chmod +x "$exe"
                  cat > "$exe" << EOF
                  #!/usr/bin/env bash
                  runtime="\$(mktemp -d)"
                  cp "$out"/lib/vite.config.* "\$runtime"
                  cp -R "$out"/lib/node_modules "\$runtime"/node_modules
                  chmod -R u+rwX,go+rX,go-w "\$runtime"/*

                  cd "$out"/lib
                  deno task preview -c "\$runtime"/vite.config.*
                  rm "\$runtime"/vite.config.*
                  rm -rf "\$runtime"/node_modules
                  rm -rf "\$runtime"
                  EOF
                '';
              };
            in
            pkgs.stdenv.mkDerivation package;
        }
      );

      devShells = forEachSupportedSystem (
        { pkgs }:
        let
          inherit (pkgs) writeScriptBin;
          inherit (self.checks.${pkgs.stdenv.hostPlatform.system}.pre-commit-check) shellHook enabledPackages;
        in
        {
          default = pkgs.mkShell {
            inherit shellHook;
            buildInputs =
              (builtins.attrValues {
                inherit (pkgs)
                  deno
                  prek
                  ;
              })
              ++ enabledPackages;
            packages = [
              (writeScriptBin "create-vite" ''
                ${pkgs.deno}/bin/deno run -A npm:create-vite .
              '')
            ]
            ++ (builtins.attrValues {
              inherit (pkgs)
                just
                nil
                nixfmt-rfc-style
                ;
            });
            env = {
              shell = "zsh";
              NIL_PATH = "${pkgs.nil}/bin/nil";
            };
          };
        }
      );
    };
}
