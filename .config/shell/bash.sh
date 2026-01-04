# ============================================
# bash.sh - Bash 固有設定
# ============================================

# --------------------------------------------
# Bash オプション
# --------------------------------------------
shopt -s histappend      # 履歴を追記モードに
shopt -s checkwinsize    # ウィンドウサイズ変更を検知
shopt -s cdspell         # cd のタイポを自動修正

HISTCONTROL=ignoreboth:erasedups
HISTFILESIZE=10000

# --------------------------------------------
# 補完設定
# --------------------------------------------
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

bind "set completion-ignore-case on"

# --------------------------------------------
# peco 履歴検索
# --------------------------------------------
function peco-select-history() {
    local selected
    selected=$(history | tac | awk '{$1=""; print substr($0,2)}' | awk '!a[$0]++' | peco --query "$READLINE_LINE")
    READLINE_LINE="$selected"
    READLINE_POINT=${#READLINE_LINE}
}

if command -v peco &> /dev/null; then
    bind -x '"\C-r": peco-select-history'
fi

# --------------------------------------------
# 追加設定ファイル読み込み
# --------------------------------------------
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
