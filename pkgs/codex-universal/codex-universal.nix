{ pkgs, containerPkgs, ... }:
let
  inherit (pkgs)
    dockerTools
    buildEnv
    writeTextFile
    writeShellApplication
    ;

  version = "${containerPkgs.codex.version}";
  codexImage = dockerTools.pullImage {
    imageName = "ghcr.io/openai/codex-universal";
    imageDigest = "sha256:49d6d4a7d50de60daa5fa50da3d8a153991208314924c4b1efa9b3d9e9ae4ce6";
    hash = "sha256-aOg0o5789qWN2AcB/M/T3ZLVXnsyLD/Fr92icMOoxEE=";
  };
  nixConfig = writeTextFile {
    name = "nixConfig";
    text = ''
      experimental-features = nix-command flakes
    '';
    destination = "/root/.config/nix/nix.conf";
  };
  codexConfig = writeTextFile {
    name = "codexConfig";
    text = builtins.readFile ./config.toml;
    destination = "/root/.codex/config.toml";
  };
  codexAgents = writeTextFile {
    name = "codexAgents";
    text = builtins.readFile ./AGENTS.md;
    destination = "/root/.codex/AGENTS.md";
  };
  codexUniversal = dockerTools.buildImage {
    name = "codex-universal";
    tag = version;
    fromImage = codexImage;
    copyToRoot = [
      (buildEnv {
        name = "image-root";
        paths = with containerPkgs; [
          bash
          codex
          nix
        ];
        pathsToLink = [ "/bin" ];
      })
      (buildEnv {
        name = "image-home";
        paths = [
          nixConfig
          codexConfig
          codexAgents
        ];
        pathsToLink = [ "/root" ];
      })
    ];
    extraCommands = ''
      mkdir -p workspace
    '';

    config = {
      Entrypoint = [ "/opt/entrypoint.sh" ];
      Env = [
        "CODEX_ENV_PYTHON_VERSION=3.13"
        "CODEX_ENV_NODE_VERSION=22"
        "CODEX_ENV_RUST_VERSION=1.87.0"
        "CODEX_ENV_GO_VERSION=1.23.8"
        "CODEX_ENV_SWIFT_VERSION=6.1.1"
      ];
      WorkingDir = "/workspace";
    };
  };
in
{
  codex-log = writeShellApplication {
    name = "codex-log";
    runtimeInputs = with pkgs; [
      gawk
      gnugrep
      podman
    ];
    text = ''
      containerId="$(podman container list | grep codex | awk -F' ' '{print $1}' | tr -s '[:blank:]')"
      podman exec -it "$containerId" tail -f /root/.codex/log/codex-tui.log
    '';
  };
  codex-enter = writeShellApplication {
    name = "codex-enter";
    runtimeInputs = with pkgs; [
      gawk
      gnugrep
      podman
    ];
    text = ''
      containerId="$(podman container list | grep codex | awk -F' ' '{print $1}' | tr -s '[:blank:]')"
      podman exec -it "$containerId" /opt/entrypoint.sh
    '';
  };
  codex-start = writeShellApplication {
    name = "codex-start";
    runtimeInputs = with pkgs; [
      gawk
      gnugrep
      podman
    ];
    text = ''
      machine="$(podman machine list | tail -n 1 | awk -F'-' '{print $1}' | tr -s '[:blank:]')"
      ollamaPid="$(pgrep ollama | head -n 1)"
      codexHome="$HOME/.codex"
      podmanOpts=("-it" "--rm" "-v" "$codexHome:/root/.codex")
      workingDir=""

      while [ $# -gt 0 ]; do
        case "$1" in
          -h|--help)
            echo -e "Start codex container\n"
            echo -e "Description:\n  Starts codex in a container without sandbox controls enabled.\n"
            echo -e "Usage:\n codex-start [options]\n"
            echo -e "Examples:\n codex-start -w /home/user/code-project\n codex-start -p 3000:3000\n"
            echo -e "Options:"
            echo -e " -h, --help              Print help message"
            echo -e " --rmi                   Removes the image when done"
            echo -e " -p string               Port option to pass to container"
            echo -e " -w, --workspace string  Workspace to mount in container"
            exit 0
          ;;
          -p)
            podmanOpts+=("-p" "$2")
            shift 2
          ;;
          --rmi)
            podmanOpts+=("--rmi")
            shift
          ;;
          -w|--workspace)
            workingDir="$2"
            podmanOpts+=("-v" "$workingDir:/workspace/$(basename "$workingDir")" "-w" "/workspace/$(basename "$workingDir")")
            shift 2
          ;;
          --workspace=*)
            workingDir="''${1/*=/}"
            podmanOpts+=("-v" "$workingDir:/workspace/$(basename "$workingDir")" "-w" "/workspace/$(basename "$workingDir")")
            shift
          ;;
          *)
            echo "$1 is not a valid command" >&2
            exit 1
          ;;
        esac
      done

      if [ -z "$workingDir" ]; then
        workingDir="$(pwd)"
        podmanOpts+=("-v" "$workingDir:/workspace/$(basename "$workingDir")" "-w" "/workspace/$(basename "$workingDir")")
      fi

      if [ -z "$ollamaPid" ]; then
        echo "Must have ollama running to use" >&2
        exit 1
      fi

      if [ -z "$machine" ]; then
        podman machine init -m 4096
      fi
      set +o errexit
      podman machine start 2>/dev/null
      set -o errexit

      imageId="$(podman images -n localhost/codex-universal:${version} | tail -n 1 | awk -F' ' '{print $3}' | tr -s '[:blank:]')"
      if [ -z "$imageId" ]; then
        echo "Loading container image..."
        podman image load -i ${codexUniversal}
      fi

      mkdir -p "$codexHome"
      ln -fs ${codexAgents}/root/.codex/AGENTS.md "$codexHome/AGENTS.md"
      ln -fs ${codexConfig}/root/.codex/config.toml "$codexHome/config.toml"

      echo "Starting container..."
      podman run "''${podmanOpts[@]}" localhost/codex-universal:${version} '-c' '/usr/bin/sh -c "codex"'
    '';
  };
}
