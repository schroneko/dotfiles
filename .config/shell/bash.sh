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
# fzf + ghq
# --------------------------------------------
if command -v fzf &> /dev/null; then
    eval "$(fzf --bash)"

    if command -v ghq &> /dev/null; then
        function ghq-fzf() {
            local repo=$(ghq list -p | fzf)
            if [[ -n "$repo" ]]; then
                cd "$repo"
            fi
        }
        bind -x '"\C-g": ghq-fzf'
    fi
fi

# --------------------------------------------
# 追加設定ファイル読み込み
# --------------------------------------------
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
