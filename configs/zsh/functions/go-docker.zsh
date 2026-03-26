# Docker Go runner / dev environment helper (macOS)
# Neovim config is COPIED into container (not mounted)

go-docker() {
  local OPTIND
  local host_path=""
  local container_path="/workspace"
  local image="go-nvim"
  local copy_nvim=0
  local mode="run"
  local cname="go-dev"
  local init_mod=0

  while getopts ":p:i:c:nsaxIh" opt; do
    case "$opt" in
      p) host_path="$OPTARG" ;;
      i) image="$OPTARG" ;;
      c) cname="$OPTARG" ;;
      n) copy_nvim=1 ;;
      s) mode="start" ;;
      a) mode="attach" ;;
      x) mode="stop" ;;
      I) init_mod=1 ;;
      h)
        cat <<'EOF'
Usage:
  go-docker -p <path> [-i <image>] [-c <name>] [-n] [-- cmd]   Run ephemeral container
  go-docker -p <path> [-i <image>] [-c <name>] [-n] -s         Start persistent container
  go-docker [-c <name>] -a                                     Attach to container
  go-docker [-c <name>] -x                                     Stop and remove container

Flags:
  -p <path>   Host path to mount (required for run/start)
  -i <image>  Docker image (default: go-nvim)
  -c <name>   Container name (default: go-dev)
  -n          Copy Neovim config into container
  -s          Start persistent dev container (detached)
  -a          Attach to running container
  -x          Stop and remove container
  -I          Run 'go mod init' if no go.mod exists
  -h          Show this help
EOF
        return 0
        ;;
      *)
        echo "Invalid option: -$OPTARG (use -h for help)"
        return 1
        ;;
    esac
  done
  shift $((OPTIND - 1))

  if [[ "$mode" == "stop" ]]; then
    if docker ps -a --format '{{.Names}}' | grep -qx "$cname"; then
      docker stop "$cname" && docker rm "$cname"
      echo "Container '$cname' stopped and removed."
    else
      echo "Container '$cname' not found."
    fi
    return $?
  fi

  if [[ "$mode" == "attach" ]]; then
    if ! docker ps --format '{{.Names}}' | grep -qx "$cname"; then
      echo "Container '$cname' is not running."
      return 1
    fi
    docker exec -it "$cname" bash
    return $?
  fi

  if [[ -z "$host_path" ]]; then
    echo "Error: -p <host_path> is required for run/start mode"
    return 1
  fi

  host_path="$(cd "$host_path" 2>/dev/null && pwd)" || {
    echo "Error: Invalid path '$host_path'"
    return 1
  }

  if ! docker image inspect "$image" &>/dev/null; then
    echo "Image '$image' not found. Build it first:"
    echo "  docker build -t $image ~/Projects/goproject/"
    return 1
  fi

  local go_build_cache="$HOME/Library/Caches/go-build"
  local go_mod_cache="$HOME/go/pkg/mod"
  mkdir -p "$go_build_cache" "$go_mod_cache"

  local -a run_args=(
    -v "$host_path":"$container_path"
    -v "$go_build_cache":/root/.cache/go-build
    -v "$go_mod_cache":/go/pkg/mod
    -w "$container_path"
  )

  if [[ "$mode" == "start" ]]; then
    if docker ps -a --format '{{.Names}}' | grep -qx "$cname"; then
      echo "Container '$cname' already exists."
      echo "  Use -a to attach, or -x to stop/remove first."
      return 1
    fi

    docker run -d --name "$cname" "${run_args[@]}" "$image" sleep infinity

    if [[ "$copy_nvim" -eq 1 && -d "$HOME/.config/nvim" ]]; then
      echo "Copying nvim config..."
      docker cp "$HOME/.config/nvim/." "$cname:/root/.config/nvim"
    fi

    if [[ "$init_mod" -eq 1 && ! -f "$host_path/go.mod" ]]; then
      local mod_name="${host_path:t}"
      echo "Initializing go module '$mod_name'..."
      docker exec "$cname" go mod init "$mod_name"
    fi

    echo "Container '$cname' started. Use 'go-docker -a' to attach."
    return 0
  fi

  if [[ "$copy_nvim" -eq 1 && -d "$HOME/.config/nvim" ]]; then
    run_args+=(-v "$HOME/.config/nvim":/root/.config/nvim:ro)
  fi

  if [[ "$init_mod" -eq 1 && ! -f "$host_path/go.mod" ]]; then
    local mod_name="${host_path:t}"
    echo "Initializing go module '$mod_name'..."
    docker run --rm -it "${run_args[@]}" "$image" bash -c "go mod init '$mod_name' && ${*:-bash}"
  else
    docker run --rm -it "${run_args[@]}" "$image" "${@:-bash}"
  fi
}
