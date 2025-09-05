{
  pkgs,
  containerPkgs,
  openaiResponses,
  ...
}:
let
  inherit (pkgs)
    dockerTools
    buildEnv
    writeTextFile
    writeShellApplication
    lib
    ;

  version = "${containerPkgs.codex.version}";
  caddyfile = writeTextFile {
    name = "codex-universal-caddyfile";
    text = builtins.readFile ./Caddyfile;
    destination = "/Caddyfile";
  };
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
  codexFramework = (import ./framework { inherit pkgs; });
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
          codexFramework
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
        "OPENAI_BASE_URL=http://host.docker.internal"
        "OPENAI_API_KEY=''"
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
      caddy
      gawk
      gnugrep
      ollama
      openaiResponses
      podman
    ];
    runtimeEnv = {
      OLLAMA_CONTEXT_LENGTH = 128000;
      OLLAMA_ORIGINS = (
        lib.strings.concatStringsSep "," [
          "http://localhost"
          "http://host.docker.internal"
          "http://localhost:*"
          "http://host.docker.internal:*"
        ]
      );
    };
    text = ''
      machine="$(podman machine inspect | jq '.[].Name' || true)"
      ollamaPid="$(pgrep -o ollama | head -n 1 || true)"
      responsesPid="$(pgrep -f responses_api | head -n 1 || true)"
      caddyPid="$(pgrep caddy | head -n 1 || true)"
      codexHome="$HOME/.codex"
      podmanOpts=("-it" "--rm" "-v" "$codexHome:/root/.codex")
      workingDir=""
      codexExec=""
      managedPids=()
      managingCaddy=""


      positionalArgs=()
      while [ $# -gt 0 ]; do
        case "$1" in
          -h|--help)
            cat << EOF
      Start codex container

      Description:
        Starts codex in a container without sandbox controls enabled.

      Usage:
        codex-start [options]

      Examples:
        codex-start -w /home/user/code-project
        codex-start -p 3000:3000

      Options:
        -h, --help              Print help message
        --rmi                   Removes the image when done
        -p string               Port option to pass to container
        -w, --workspace string  Workspace to mount in container
        -e, --exec              Execute prompt in non-interactive mode
        -c, --context           Ollama context length in tokens
      EOF
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
          -e|--exec)
            codexExec="exec"
            shift
          ;;
          -c|--context)
            OLLAMA_CONTEXT_LENGTH="$2"
            shift 2
          ;;
          --context=*)
            OLLAMA_CONTEXT_LENGTH="''${1/*=}"
            shift
          ;;
          -*)
            printf "'%s' is not a valid command\n" "$1" >&2
            exit 1
          ;;
          *)
            positionalArgs+=("$1")
            shift
          ;;
        esac
      done

      set -- "''${positionalArgs[@]}"

      if [ -z "$workingDir" ]; then
        workingDir="$(pwd)"
        podmanOpts+=("-v" "$workingDir:/workspace/$(basename "$workingDir")" "-w" "/workspace/$(basename "$workingDir")")
      fi

      if [ -z "$ollamaPid" ]; then
        printf "Starting Ollama..."
        set +o errexit
        env OLLAMA_ORIGINS="$OLLAMA_ORIGINS" OLLAMA_CONTEXT_LENGTH="$OLLAMA_CONTEXT_LENGTH" ollama serve > /dev/null 2>&1 &
        managedPids+=($!)
        set -o errexit
        printf "\rdone.....................\n\n"
      fi

      if [ -z "$responsesPid" ]; then
        responsesHome="$HOME/.local/state/openai-responses"
        mkdir -p "$responsesHome"
        printf "Starting Responses API..."
        set +o errexit
        responses_api --checkpoint 'gpt-oss:20b' --port 3000 --inference-backend ollama > "$responsesHome/logs.txt" 2>&1 &
        managedPids+=($!)
        set -o errexit
        printf "\rdone.....................\n\n"
      fi

      if [ -z "$caddyPid" ]; then
        printf "Starting Cuddy..."
        set +o errexit
        caddy start --config ${caddyfile}/Caddyfile > /dev/null 2>&1
        managingCaddy="1"
        set -o errexit
        printf "\rdone.....................\n\n"
      fi

      if [ -z "$machine" ]; then
        podman machine init -m 4096
      fi
      set +o errexit
      podman machine start > /dev/null 2>&1
      set -o errexit

      imageId="$(podman images -n localhost/codex-universal:${version} | tail -n 1 | awk -F' ' '{print $3}' | tr -s '[:blank:]')"
      if [ -z "$imageId" ]; then
        printf "Loading container image..."
        podman image load -i ${codexUniversal} > /dev/null 2>&1
        printf "\rdone.....................\n\n"
      fi

      mkdir -p "$codexHome"
      mkdir -p "$codexHome/agents"
      mkdir -p "$codexHome/commands"
      set +o errexit
      cp -f "${codexFramework}/root/.codex/framework-instructions.md" "$codexHome/framework-instructions.md"
      cp -f "${codexFramework}/root/.codex/config.toml" "$codexHome/config.toml"
      cp -f ${codexFramework}/root/.codex/agents/* "$codexHome/agents"
      cp -f ${codexFramework}/root/.codex/commands/* "$codexHome/commands"
      set -o errexit

      printf "Starting container...\n"
      set +o errexit
      podman run "''${podmanOpts[@]}" localhost/codex-universal:${version} '-c' "/usr/bin/sh -c 'codex $codexExec \"$*\"'"
      set -o errexit

      printf "\rStopping..."
      trap "" SIGINT
      set +o errexit
      for pid in "''${managedPids[@]}"; do
        kill -2 "$pid"
        sleep 5
        check="$(ps "$pid" | tail -n 1 | awk -F' ' '{print $1}' | tr -d -c '[:digit:]')"
        if [[ "$pid" -eq "$check" ]]; then
          kill -9 "$pid"
        fi
      done
      if [ -n "$managingCaddy" ]; then
        caddy stop
      fi
      set +o errexit
      printf "\rfinished.................\n\n"
    '';
  };
}
