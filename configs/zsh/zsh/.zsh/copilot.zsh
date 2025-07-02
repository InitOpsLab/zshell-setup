# === GitHub Copilot CLI Shell Shortcuts ===

# Aliases
alias copilot-suggest='gh copilot suggest'
alias copilot-explain='gh copilot explain'
alias cs='copilot-suggest'
alias ce='copilot-explain'

# Status Function
copilot-status() {
  echo "🔍 GitHub Copilot CLI Status"
  echo "-----------------------------"
  echo "📦 Copilot CLI version: $(gh copilot --version 2>/dev/null || echo 'not installed')"
  echo "🔑 Auth status:"
  gh auth status 2>/dev/null
}

