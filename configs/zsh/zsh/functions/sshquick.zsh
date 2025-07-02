# ~/.zsh/functions/sshquick.zsh

sshquick() {
  local user=${1:-$USER}
  local host=$2
  if [ -z "$host" ]; then
    echo "Usage: sshquick [user] host"
    return 1
  fi
  ssh -o IdentitiesOnly=yes \
      -o StrictHostKeyChecking=no \
      -o UserKnownHostsFile=/dev/null \
      "$user@$host"
}

