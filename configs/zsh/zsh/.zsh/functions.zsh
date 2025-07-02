# === Prompt Enhancements ===
function aws_prompt() {
  [[ -n $AWS_PROFILE ]] && echo "AWS: ($AWS_PROFILE)"
}
function git_prompt() {
  local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  [[ -n $branch ]] && echo " $branch"
}
PROMPT='%F{cyan}%n@%m%f %F{blue}%~%f $(aws_prompt) $(git_prompt) %# '

# === History Search Keybindings (prefix-aware) ===
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# === FZF Ctrl+R History Search ===
fzf-history-widget() {
  BUFFER=$(fc -l 1 | fzf --tac +s --reverse --ansi --preview 'echo {}' --preview-window=up:1)
  CURSOR=$#BUFFER
  zle reset-prompt
}
zle -N fzf-history-widget
bindkey '^R' fzf-history-widget

# === Env Vars ===
export GOPATH="$HOME/go"
export PYENV_ROOT="$HOME/.pyenv"
[[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

# === Load All Functions ===
for f in ~/.zsh/functions/*.zsh; do
  source "$f"
done

