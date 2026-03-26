# === Bracketed Paste Mode ===
# Fixes multiline paste issues (e.g., AWS SSO credentials)
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic
  zle -N bracketed-paste _paste-no-autosuggest
}

pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}

_paste-no-autosuggest() {
  unset 'ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[${ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[(i)forward-char]}]'
  zle .bracketed-paste
  ZSH_AUTOSUGGEST_ACCEPT_WIDGETS+=(forward-char)
}
zle -N _paste-no-autosuggest

zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste)

# === Theme ===
zinit ice depth=1
zinit light romkatv/powerlevel10k
# p10k.zsh is sourced in ~/.zshrc

# === Plugin Loading ===
zinit ice wait blockf
zinit light zsh-users/zsh-syntax-highlighting

zinit ice wait lucid
zinit light zsh-users/zsh-autosuggestions

zinit ice wait
zinit light Aloxaf/fzf-tab

zinit ice wait lucid
zinit light junegunn/fzf
zinit light junegunn/fzf-bin

zinit ice wait lucid
zinit light Tarrasch/zsh-autoenv
zinit light mfaerevaag/wd

# === OMZ Plugin Snippets (deferred) ===
SHOW_AWS_PROMPT=false  # Disable OMZ aws prompt (using p10k instead)
zinit ice wait lucid; zinit snippet OMZ::plugins/git/git.plugin.zsh
zinit ice wait lucid; zinit snippet OMZ::plugins/aws/aws.plugin.zsh
zinit ice wait lucid; zinit snippet OMZ::plugins/docker/docker.plugin.zsh
zinit ice wait lucid; zinit snippet OMZ::plugins/kubectl/kubectl.plugin.zsh
zinit ice wait lucid; zinit snippet OMZ::plugins/kubectx/kubectx.plugin.zsh
zinit ice wait lucid; zinit snippet OMZ::plugins/gh/gh.plugin.zsh

# GitHub Copilot CLI shortcuts
[[ -f ~/.zsh/copilot.zsh ]] && source ~/.zsh/copilot.zsh
