# ~/.zsh/go.zsh — Go toolchain setup

# --- Go environment ---
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$(go env GOROOT)/bin:$GOBIN"

# --- Go zsh completion prep ---
# ensure the completion directory exists
mkdir -p "$HOME/.zsh/completion"
# add it to fpath so compinit will pick up _go
fpath=(~/.zsh/completion $fpath)

