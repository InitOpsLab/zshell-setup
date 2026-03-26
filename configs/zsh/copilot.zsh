# === GitHub Copilot CLI Shell Shortcuts ===

alias copilot-suggest='gh copilot suggest'
alias copilot-explain='gh copilot explain'
alias cs='copilot-suggest'
alias ce='copilot-explain'

copilot-status() {
  echo "GitHub Copilot CLI Status"
  echo "-----------------------------"
  echo "Copilot CLI version: $(gh copilot --version 2>/dev/null || echo 'not installed')"
  echo "Auth status:"
  gh auth status 2>/dev/null
}
