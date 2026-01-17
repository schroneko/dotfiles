# ============================================
# .zshrc
# ============================================

for f in ~/.config/shell/{common,zsh}.sh; do
    [ -r "$f" ] && . "$f"
done

export CLAUDE_ENV_FILE="$HOME/.claude/env-loader.sh"
export EDITOR=nvim

if [[ "$(uname)" == "Darwin" ]]; then
    alias brewup='brew update && brew upgrade --greedy && brew autoremove && brew doctor && brew cleanup'

    _update_brewfile() {
        brew bundle dump --file=~/.Brewfile --force 2>/dev/null
    }

    brew() {
        command brew "$@"
        local exit_code=$?
        case "$1" in
            install|uninstall|remove|untap) [[ $exit_code -eq 0 ]] && _update_brewfile ;;
        esac
        return $exit_code
    }

    export PATH="$PATH:$HOME/.lmstudio/bin"
    export PATH="$HOME/.mint/bin:$PATH"

    alias claude-or='ANTHROPIC_BASE_URL="https://openrouter.ai/api" ANTHROPIC_AUTH_TOKEN="$(op read "op://Personal/OPENROUTER_API_KEY/credential")" ANTHROPIC_API_KEY="" MAX_THINKING_TOKENS="0" claude'
    alias claude-mm='ANTHROPIC_BASE_URL="https://api.minimax.io/anthropic" ANTHROPIC_AUTH_TOKEN="$(op read "op://Personal/MINIMAX_API_KEY/credential")" ANTHROPIC_MODEL="MiniMax-M2.1" claude'
fi

pdfview() {
  local pdf="$1"
  local dpi="${2:-200}"
  local pages=$(mutool info "$pdf" 2>/dev/null | grep "^Pages:" | awk '{print $2}')

  if [[ "$pages" -gt 50 ]]; then
    echo "This PDF has $pages pages. Continue? [y/N]"
    read -r answer
    [[ "$answer" != [yY] ]] && return 0
  fi

  local tmp_dir="/tmp/pdfview_$$"
  mkdir -p "$tmp_dir"
  mutool draw -o "$tmp_dir/page%d.png" -r "$dpi" "$pdf"
  timg -W "$tmp_dir"/page*.png
  rm -rf "$tmp_dir"
}
