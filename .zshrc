# ============================================
# .zshrc
# ============================================

for f in ~/.config/shell/{common,zsh}.sh; do
    [ -r "$f" ] && . "$f"
done

alias python='uv run python'
alias python3='uv run python'

export CLAUDE_ENV_FILE="$HOME/.claude/env-loader.sh"
export EDITOR=nvim

if [[ "$(uname)" == "Darwin" ]]; then
    alias brewup='brew update && brew upgrade --greedy && brew autoremove && brew cleanup --prune=all && brew doctor'
    alias rm='trash'

    export PATH="$PATH:$HOME/.lmstudio/bin"
    export PATH="$HOME/.mint/bin:$PATH"

    alias claude-or='ANTHROPIC_BASE_URL="https://openrouter.ai/api" ANTHROPIC_AUTH_TOKEN="$(op read "op://Personal/OPENROUTER_API_KEY/credential")" claude'
    alias claude-mm='ANTHROPIC_BASE_URL="https://api.minimax.io/anthropic" ANTHROPIC_AUTH_TOKEN="$(op read "op://Personal/MINIMAX_API_KEY/credential")" ANTHROPIC_MODEL="MiniMax-M2.1" claude'
fi
