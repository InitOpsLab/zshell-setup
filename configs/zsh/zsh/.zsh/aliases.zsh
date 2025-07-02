# === General Aliases ===
alias ls='gls --color=auto'
alias ll='ls -laFh --group-directories-first'
alias please="sudo"

# === Dev Aliases ===
alias push-upstream='git push --set-upstream origin $(git branch --show-current)'
alias clean-terragrunt='find . -name ".terraform.lock.hcl" -exec rm -f {} \; && find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;'

