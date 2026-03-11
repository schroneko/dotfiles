# ============================================
# zsh.sh - Zsh 固有設定
# ============================================

# --------------------------------------------
# PATH 重複除去
# --------------------------------------------
typeset -U PATH path
path=(${path:#$HOME/.volta/bin})

if command -v mise &> /dev/null; then
    eval "$(mise activate zsh)"
fi

# --------------------------------------------
# dotfiles: git hooks path
# --------------------------------------------
if [[ -d "$HOME/dotfiles/.githooks" ]]; then
    git -C "$HOME/dotfiles" config core.hooksPath .githooks 2>/dev/null
fi

# --------------------------------------------
# Zsh オプション
# --------------------------------------------
setopt prompt_subst         # プロンプト展開を有効化
setopt auto_cd              # ディレクトリ名だけで cd
setopt hist_ignore_dups     # 連続する重複コマンドを履歴に残さない
setopt hist_reduce_blanks   # 余分な空白を削除
setopt hist_save_no_dups    # 重複コマンドを履歴ファイルに保存しない
setopt share_history        # 履歴をセッション間で共有
setopt complete_in_word     # 単語の途中でも補完

# --------------------------------------------
# 補完設定
# --------------------------------------------
autoload -U +X compinit && compinit

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # 大文字小文字を区別しない
zstyle ':completion:*' menu select                          # メニュー選択を有効化

# --------------------------------------------
# fzf + ghq
# --------------------------------------------
if command -v fzf &> /dev/null; then
    source <(fzf --zsh)

    if command -v ghq &> /dev/null; then
        function ghq-fzf() {
            local repo=$(ghq list -p | fzf)
            if [[ -n "$repo" ]]; then
                BUFFER="cd ${(q)repo}"
                zle accept-line
            fi
            zle reset-prompt
        }
        zle -N ghq-fzf
        bindkey '^G' ghq-fzf
    fi
fi

# --------------------------------------------
# precmd: プロンプト前に空行（初回除く）
# --------------------------------------------
precmd() {
  if [ -z "$_FIRST_PROMPT" ]; then
    _FIRST_PROMPT=1
  else
    echo
  fi
}

# --------------------------------------------
# プラグイン
# --------------------------------------------
if [ -n "$HOMEBREW_PREFIX" ]; then
    [ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
        source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    [ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
        source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
