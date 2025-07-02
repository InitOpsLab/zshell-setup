# ~/.zsh/functions/scpquick.zsh

scpquick() {
  local user=$1
  local host=$2
  shift 2

  if [[ -z "$host" || "$#" -lt 2 ]]; then
    echo "Usage: scpquick user host src1 [src2 ...] dest"
    return 1
  fi

  local dest="${@: -1}"
  local -a sources=("${@:1:$#-1}")

  echo "DEBUG: SCP from sources (${sources[*]}) to ${user}@${host}:${dest}"

  scp -o IdentitiesOnly=yes \
      -o StrictHostKeyChecking=no \
      -o UserKnownHostsFile=/dev/null \
      "${sources[@]}" "${user}@${host}:${dest}"
}

