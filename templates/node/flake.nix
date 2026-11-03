{
  description = "A Nix flake based Node.js environment";
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
              nixfmt = {
                enable = true;
                name = "🔍 Code Quality · ❄️ Nix · Format";
                after = [ "trufflehog" ];
              };
              oxfmt = {
                enable = true;
                name = "🔍 Code Quality · 🟢 Node · Format";
                after = [ "trufflehog" ];
              };
              oxlint = {
                enable = true;
                name = "🔍 Code Quality · 🟢 Node · Lint";
                after = [ "oxfmt" ];
              };
              flake-checker = {
                enable = true;
                name = "✅ Data & Config Validation · ❄️ Nix · Flake checker";
                args = [
                  "--check-supported"
                  "false"
                ];
                after = [
                  "nixfmt"
                  "oxlint"
                ];
              };
              check-yaml = {
                enable = true;
                name = "✅ Data & Config Validation · YAML · Lint";
                after = [
                  "nixfmt"
                  "oxlint"
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
                after = [ "mdformat" ];
              };
              check-symlinks = {
                enable = true;
                name = "📁 Filesystem · Check symlinks";
                after = [ "mdformat" ];
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
              # Pin the pnpm major version for reproducible builds.
              # Regenerate this if you switch to a different pnpm major version.
              pnpm = pkgs.pnpm_11;
            in
            pkgs.stdenv.mkDerivation (finalAttrs: {
              pname = "node-template";
              version = "0.1.0";
              src = builtins.path {
                path = ./.;
                name = "template";
              };

              nativeBuildInputs = [
                # Needed in case scripts are run outside of a pnpm call
                pkgs.nodejs
                # Prepares the build environment to install the pre-fetched dependency store
                pkgs.pnpmConfigHook
                pnpm
              ];

              # Pre-fetches the pnpm dependency store from pnpm-lock.yaml
              pnpmDeps = pkgs.fetchPnpmDeps {
                inherit (finalAttrs) pname version src;
                inherit pnpm;
                fetcherVersion = 5;
                hash = "sha256-8ThnXzrrPEyp6uDhc0OpQT0m8zIJDEWwZvJyIYPpnUE=";
              };

              buildPhase = ''
                runHook preBuild
                pnpm run build
                runHook postBuild
              '';

              installPhase = ''
                mkdir -p "$out"/bin "$out"/lib
                cp -a dist "$out"/lib/dist
                cp -a node_modules "$out"/lib/node_modules
                chmod -R u+rwX,go+rX,go-w "$out"/lib

                cat > "$out"/bin/${finalAttrs.pname} << EOF
                #!/usr/bin/env bash
                export PATH="${pkgs.nodejs}/bin:\$PATH"
                cd "$out"/lib
                host=0.0.0.0
                [ -n "\$HOST" ] && host=\$HOST
                port=4173
                [ -n "\$PORT" ] && port=\$PORT
                exec ./node_modules/.bin/vite preview --host "\$host" --port "\$port"
                EOF
                chmod +x "$out"/bin/${finalAttrs.pname}
              '';
            });
        }
      );

      devShells = forEachSupportedSystem (
        { pkgs }:
        let
          inherit (pkgs) writeScriptBin;
          inherit (self.checks.${pkgs.stdenv.hostPlatform.system}.pre-commit-check) shellHook enabledPackages;
          # Pin the pnpm major version to match the lockfile version
          pnpm = pkgs.pnpm_11;
        in
        {
          default = pkgs.mkShell {
            inherit shellHook;
            buildInputs =
              (builtins.attrValues {
                inherit (pkgs)
                  nodejs
                  prek
                  ;
              })
              ++ enabledPackages;
            packages = [
              pnpm
              (writeScriptBin "create-vite" ''
                ${pnpm}/bin/pnpm create vite .
              '')
            ]
            ++ (builtins.attrValues {
              inherit (pkgs)
                nil
                nixfmt
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
