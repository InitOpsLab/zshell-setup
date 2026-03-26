# === Word Motion Bindings (Option/Alt arrows and Emacs style) ===
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^[f" forward-word
bindkey "^[b" backward-word
bindkey "^[^?" backward-kill-word
autoload -U select-word-style
select-word-style bash

# === Home / End Key Fixes (iTerm2 and alternate terminals) ===
bindkey '\e[H' beginning-of-line
bindkey '\e[F' end-of-line
bindkey '\eOH' beginning-of-line
bindkey '\eOF' end-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line

# === Cmd+Left / Cmd+Right (map to Ctrl+A / Ctrl+E in iTerm2) ===
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
