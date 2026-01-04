# ============================================
# .zshrc
# ============================================

# シェル設定を読み込み
for f in ~/.config/shell/{common,zsh}.sh; do
    [ -r "$f" ] && . "$f"
done

alias brewup='brew update && brew upgrade --greedy && brew autoremove && brew cleanup --prune=all && brew doctor'
alias rm='trash'
alias python='uv run python'
alias python3='uv run python'

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/username/.lmstudio/bin"
# End of LM Studio CLI section

# Mint (Swift CLI tool manager)
export PATH="$HOME/.mint/bin:$PATH"

# Claude Code: auto-load .dev.vars
export CLAUDE_ENV_FILE="$HOME/.claude/env-loader.sh"

export EDITOR=nvim

alias claude-or='ANTHROPIC_BASE_URL="https://openrouter.ai/api" ANTHROPIC_AUTH_TOKEN="$(op read "op://Personal/OPENROUTER_API_KEY/credential")" claude'
alias claude-mm='ANTHROPIC_BASE_URL="https://api.minimax.io/anthropic" ANTHROPIC_AUTH_TOKEN="$(op read "op://Personal/MINIMAX_API_KEY/credential")" ANTHROPIC_MODEL="MiniMax-M2.1" claude'
