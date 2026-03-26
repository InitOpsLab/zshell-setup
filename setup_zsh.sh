#!/bin/bash
set -euo pipefail

# ──────────────────────────────────────────────────────────────────────
# Logging Colors
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

log_info()  { echo -e "${GREEN}[INFO]${RESET} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${RESET} $1"; }
log_error() { echo -e "${RED}[ERROR]${RESET} $1"; exit 1; }

ask_yes_no() {
  local prompt="$1"
  local default="${2:-n}"
  local yn_hint="[y/N]"
  [[ "$default" == "y" ]] && yn_hint="[Y/n]"

  while true; do
    echo -n -e "${GREEN}[?]${RESET} ${prompt} ${yn_hint} "
    read -r answer
    answer="${answer:-$default}"
    case "$(echo "$answer" | tr '[:upper:]' '[:lower:]')" in
      y|yes) return 0 ;;
      n|no)  return 1 ;;
      *)     echo "Please answer y or n." ;;
    esac
  done
}

# ──────────────────────────────────────────────────────────────────────
# Paths
CONFIGS_DIR="$(pwd)/configs"
ZSHRC_FILE="$CONFIGS_DIR/zshrc"
ZSH_CUSTOM_DIR="$CONFIGS_DIR/zsh"
ZSH_TARGET_DIR="$HOME/.zsh"
TG_VERSION="0.53.2"
TG_BIN="$HOME/.tgenv/versions/$TG_VERSION/terragrunt"

# ──────────────────────────────────────────────────────────────────────
# Checkers
is_installed() {
  command -v "$1" >/dev/null 2>&1
}

install_if_missing() {
  if ! is_installed "$1"; then
    log_info "Installing $1..."
    brew install "$1" || log_warn "Failed to install $1"
  else
    log_info "$1 is already installed."
  fi
}

# ──────────────────────────────────────────────────────────────────────
detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
    log_info "Operating system: macOS"
  elif [[ -f "/etc/lsb-release" ]]; then
    OS="Ubuntu"
    log_info "Operating system: Ubuntu"
  else
    log_error "Unsupported OS. Exiting."
  fi
}

# ──────────────────────────────────────────────────────────────────────
install_dependencies() {
  if [[ "$OS" == "macOS" ]]; then
    brew update || log_warn "brew update failed"

    for pkg in zsh git fzf coreutils gnu-sed gnupg gawk fd ripgrep bat eza pyenv neovim terraform awscli gh tfenv cookiecutter tgenv; do
      install_if_missing "$pkg"
    done

    if ! tfenv list | grep -q '1.3.7'; then
      log_info "Installing Terraform 1.3.7 via tfenv..."
      tfenv install 1.3.7 || log_warn "tfenv failed to install Terraform"
    fi

    tfenv use 1.3.7 || log_warn "Failed to activate Terraform 1.3.7 — check tfenv configuration."

    if [[ ! -f "$TG_BIN" ]]; then
      log_info "Installing Terragrunt $TG_VERSION via tgenv..."
      tgenv install "$TG_VERSION" || log_error "Terragrunt install failed via tgenv"
    else
      log_info "Terragrunt $TG_VERSION already installed at $TG_BIN"
    fi

    chmod +x "$TG_BIN" || log_warn "Could not chmod $TG_BIN"
    xattr -d com.apple.quarantine "$TG_BIN" 2>/dev/null || log_warn "Quarantine attribute may still exist"

    if [[ ! -x /usr/local/bin/sops ]]; then
      log_info "Installing SOPS..."
      curl -Lo /usr/local/bin/sops https://github.com/getsops/sops/releases/download/v3.7.3/sops-v3.7.3.darwin.arm64 || log_warn "SOPS download failed"
      chmod +x /usr/local/bin/sops || log_warn "Could not chmod sops"
      xattr -d com.apple.quarantine /usr/local/bin/sops 2>/dev/null || log_warn "Quarantine attribute may still exist on SOPS"
    else
      log_info "SOPS already installed."
    fi
  else
    log_error "Currently only macOS is supported in this script."
  fi

  if [[ "$SHELL" != *zsh ]]; then
    log_info "Changing default shell to Zsh..."
    chsh -s "$(which zsh)" || log_warn "Failed to change default shell to zsh"
  fi
}

# ──────────────────────────────────────────────────────────────────────
install_zinit() {
  if [[ ! -f ~/.zinit/bin/zinit.zsh ]]; then
    log_info "Installing Zinit plugin manager..."
    mkdir -p ~/.zinit
    git clone https://github.com/zdharma-continuum/zinit ~/.zinit/bin || log_warn "Failed to clone zinit"
  else
    log_info "Zinit already installed. Skipping."
  fi
}

# ──────────────────────────────────────────────────────────────────────
copy_zsh_configs() {
  log_info "Copying .zshrc to home directory (if not already present)..."
  [[ -f ~/.zshrc ]] || cp "$ZSHRC_FILE" ~/.zshrc

  log_info "Copying custom Zsh configs to ~/.zsh..."
  mkdir -p "$ZSH_TARGET_DIR"
  cp -Rn "$ZSH_CUSTOM_DIR/"* "$ZSH_TARGET_DIR/" || log_warn "Failed to copy custom Zsh configs"

  mkdir -p "$ZSH_TARGET_DIR/functions"
}

# ──────────────────────────────────────────────────────────────────────
configure_subscription_plugins() {
  log_info "Subscription plugins are off by default. Enable them if you have the required subscription."
  echo ""

  if ask_yes_no "Enable GitHub Copilot CLI shortcuts? (requires GitHub Copilot subscription)"; then
    log_info "Copilot CLI shortcuts enabled."
  else
    rm -f "$ZSH_TARGET_DIR/copilot.zsh"
    log_info "Copilot CLI shortcuts disabled (remove ~/.zsh/copilot.zsh to disable later)."
  fi
}

# ──────────────────────────────────────────────────────────────────────
setup_powerlevel10k() {
  if [[ ! -f ~/.p10k.zsh ]]; then
    log_info "Installing Powerlevel10k default theme config..."
    curl -fsSL https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/config/p10k-classic.zsh -o ~/.p10k.zsh || log_warn "Failed to download Powerlevel10k config"
  else
    log_info "Powerlevel10k config already exists. Skipping."
  fi
}

# ──────────────────────────────────────────────────────────────────────
validate_plugins() {
  log_info "Running Zsh headless mode to bootstrap plugins..."
  zsh -i -c "source ~/.zshrc; zinit self-update; zinit update --all" || log_warn "Zinit plugin initialization failed or incomplete"
}

# ──────────────────────────────────────────────────────────────────────
wrap_up() {
  log_info "✅ Zsh setup complete."
  echo -e "${YELLOW}➡️  Restart your terminal or run \`exec zsh\` to start using your new shell.${RESET}"
}

# ──────────────────────────────────────────────────────────────────────
# Execute
detect_os
install_dependencies
install_zinit
copy_zsh_configs
configure_subscription_plugins
setup_powerlevel10k
validate_plugins
wrap_up
