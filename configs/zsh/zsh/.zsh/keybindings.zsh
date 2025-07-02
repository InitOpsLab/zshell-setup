# === Word Motion Bindings (Option/Alt arrows and Emacs style) ===
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^[f" forward-word
bindkey "^[b" backward-word
bindkey "^[^?" backward-kill-word
autoload -U select-word-style
select-word-style bash

# === Home / End Key Fixes (iTerm2 and alternate terminals) ===
bindkey '\e[H' beginning-of-line        # Home
bindkey '\e[F' end-of-line              # End
bindkey '\eOH' beginning-of-line        # Alternate Home
bindkey '\eOF' end-of-line              # Alternate End
bindkey '^[[1~' beginning-of-line       # iTerm/Linux Home
bindkey '^[[4~' end-of-line             # iTerm/Linux End

# === ⌘← / ⌘→ (iTerm2 should send Ctrl+A / Ctrl+E for these) ===
bindkey '^A' beginning-of-line          # Ctrl+A / Cmd+Left
bindkey '^E' end-of-line                # Ctrl+E / Cmd+Right

