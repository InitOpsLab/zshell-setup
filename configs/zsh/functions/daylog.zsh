# daylog - Daily engineering context manager (zsh integration)
# Source this from ~/.zshrc:
#   [[ -f ~/.zsh/functions/daylog.zsh ]] && source ~/.zsh/functions/daylog.zsh

[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

alias dl='daylog'
alias dl-sod='daylog sod'
alias dl-eod='daylog eod'
alias ds='daylog status'
alias dl-log='daylog log'
alias dl-edit='daylog edit'
alias dl-digest='daylog digest'
alias dl-standup='daylog standup'
alias dl-eow='daylog eow'
alias dl-wiz='daylog wiz'
alias dl-yday='daylog yesterday'
alias dl-oncall='daylog sod --oncall'
alias dl-carryon='daylog oncall-carryon'

dl-note() { daylog log "$*"; }
dl-search() { daylog search "$*"; }

_daylog() {
    local -a commands
    commands=(
        'sod:Start of day briefing'
        'eod:End of day reflection'
        'status:Show today'\''s context'
        's:Show today'\''s context (short)'
        'log:Add timestamped note'
        'l:Add timestamped note (short)'
        'focus:Set today'\''s focus'
        'edit:Open today'\''s file in editor'
        'e:Open today'\''s file (short)'
        'digest:AI-powered context analysis'
        'report:Aggregate summary'
        'eow:End of week summary (Sun-Thu)'
        'oncall-carryon:On-call handoff message for the next firefighter'
        'standup:Generate Slack standup'
        'search:Search across daily files'
        'yesterday:Retroactive EOD for yesterday'
        'yday:Retroactive EOD (short)'
        'remind:Manage EOD reminder'
        'setup:Show setup status'
        'help:Show help'
    )

    if (( CURRENT == 2 )); then
        _describe -t commands 'daylog command' commands
    else
        case "${words[2]}" in
            sod)
                _arguments '--auto[Non-interactive mode]' '--force[Recreate today file]' '--oncall[On-call mode]'
                ;;
            report)
                _arguments '--week[Last 7 days]' '--range[Date range]' '--clipboard[Copy to clipboard]' '--markdown[Markdown output]' '--slack[Slack format + clipboard]'
                ;;
            eow)
                _arguments '--clipboard[Copy to clipboard]' '--slack[Slack format + clipboard]'
                ;;
            oncall-carryon)
                _arguments '--clipboard[Copy to clipboard]'
                ;;
            standup)
                _arguments '--clipboard[Copy to clipboard]'
                ;;
            digest)
                _arguments '--week[Analyze whole week]'
                ;;
            remind)
                local -a actions
                actions=('on:Enable reminder' 'off:Disable reminder' 'status:Show config')
                _describe -t actions 'remind action' actions
                ;;
        esac
    fi
}

if (( $+functions[compdef] )); then
    compdef _daylog daylog
fi
