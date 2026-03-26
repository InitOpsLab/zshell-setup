# === History Search Keybindings (prefix-aware) ===
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# === FZF Ctrl+R History Search ===
fzf-history-widget() {
  local selected
  selected=$(builtin fc -rl 1 | \
    sed -E 's/^[[:space:]]*[0-9]+[[:space:]]+//' | \
    fzf --ansi --reverse --query="$LBUFFER" --preview 'echo {}' --preview-window=up:1)
  if [[ -n $selected ]]; then
    BUFFER=$selected
    CURSOR=${#BUFFER}
    zle reset-prompt
  fi
}
zle -N fzf-history-widget
bindkey '^R' fzf-history-widget

# === Env Vars ===
export GOPATH="${GOPATH:-$(go env GOPATH 2>/dev/null || echo "$HOME/go")}"
export PYENV_ROOT="$HOME/.pyenv"

# Put Go tools (gofumpt, goimports, etc.) on PATH
case ":$PATH:" in
  *":$GOPATH/bin:"*) ;;
  *) export PATH="$PATH:$GOPATH/bin" ;;
esac

[[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path 2>/dev/null || true)"
eval "$(pyenv init - 2>/dev/null || true)"

# === Load All Functions ===
setopt null_glob
for f in ~/.zsh/functions/*.zsh; do
  source "$f"
done
unsetopt null_glob
