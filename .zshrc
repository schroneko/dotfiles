# ============================================
# .zshrc
# ============================================

# シェル設定を読み込み
for f in ~/.config/shell/{common,zsh}.sh; do
    [ -r "$f" ] && . "$f"
done

alias brewup='brew update && brew upgrade --greedy && brew autoremove && brew cleanup --prune=all && brew doctor && git -C ~/dotfiles diff --quiet || (git -C ~/dotfiles add -A && git -C ~/dotfiles commit -m "sync dotfiles" && git -C ~/dotfiles push)'

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/username/.lmstudio/bin"
# End of LM Studio CLI section

# Mint (Swift CLI tool manager)
export PATH="$HOME/.mint/bin:$PATH"

# Claude Code: auto-load .dev.vars
export CLAUDE_ENV_FILE="$HOME/.claude/env-loader.sh"

export EDITOR=nvim
