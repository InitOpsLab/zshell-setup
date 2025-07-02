# === Theme ===
zinit ice depth=1
zinit light romkatv/powerlevel10k
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

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

# === OMZ Plugin Snippets ===
zinit snippet OMZ::plugins/git/git.plugin.zsh
zinit snippet OMZ::plugins/aws/aws.plugin.zsh
zinit snippet OMZ::plugins/docker/docker.plugin.zsh
zinit snippet OMZ::plugins/kubectl/kubectl.plugin.zsh
zinit snippet OMZ::plugins/kubectx/kubectx.plugin.zsh
zinit snippet OMZ::plugins/gh/gh.plugin.zsh

# === GitHub Copilot CLI Plugin (correct file) ===
[[ -f ~/.zsh/copilot.zsh ]] && source ~/.zsh/copilot.zsh
