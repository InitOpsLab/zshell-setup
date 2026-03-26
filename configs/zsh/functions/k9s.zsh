# K9s launcher helpers

if type k9s &>/dev/null; then

  alias k9='k9s'

  # Local kind test cluster
  function k9l() {
    echo "Launching K9s (local-kind)..."
    k9s --context local-kind
  }

  # Staging cluster
  function k9st() {
    echo "Launching K9s (staging)..."
    k9s --context staging
  }

  # Production cluster (read-only)
  function k9p() {
    echo "Launching K9s (production, READ-ONLY)..."
    k9s --context prod --readonly
  }

  # Current context shortcut
  function k9c() {
    local ctx=$(kubectl config current-context)
    echo "Launching K9s for current context: $ctx"
    k9s --context "$ctx"
  }

fi
