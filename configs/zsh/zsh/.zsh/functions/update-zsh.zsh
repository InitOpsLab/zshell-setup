# ~/.zsh/functions/update_zsh.zsh

update_zsh() {
  echo "🔄 Updating system packages..."

  if [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &>/dev/null; then
      brew update && brew upgrade
    else
      echo "⚠️ Homebrew not found."
    fi
  elif [[ -f /etc/lsb-release ]]; then
    sudo apt update && sudo apt upgrade -y
  else
    echo "❌ Unsupported OS for system package updates."
    return 1
  fi

  echo "🔄 Updating Zinit and plugins..."
  zsh -i -c "zinit self-update && zinit update --all"

  echo "✅ Zsh environment fully updated."
}

