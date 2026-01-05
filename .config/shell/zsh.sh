# ============================================
# zsh.sh - Zsh 固有設定
# ============================================

# --------------------------------------------
# PATH 重複除去
# --------------------------------------------
typeset -U PATH path

# --------------------------------------------
# Zsh オプション
# --------------------------------------------
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
# peco 履歴検索
# --------------------------------------------
function peco-select-history() {
    BUFFER=$(fc -l -n 1 | tail -r | awk '!a[$0]++' | peco --query "$LBUFFER")
    CURSOR=${#BUFFER}
}

if command -v peco &> /dev/null; then
    zle -N peco-select-history
    bindkey '^R' peco-select-history
fi

# --------------------------------------------
# brew 関数（install/uninstall 時に Brewfile 自動更新）
# --------------------------------------------
if command -v brew &> /dev/null; then
    function _update_brewfile() {
        {
            command brew tap
            command brew leaves --installed-on-request | sed 's/^/brew "/' | sed 's/$/"/'
            command brew list --cask -1 | sed 's/^/cask "/' | sed 's/$/"/'
        } > ~/.Brewfile
        echo "Brewfile updated"
    }

    function brew() {
        command brew "$@"
        local exit_code=$?
        case "$1" in
            install|uninstall|remove|untap)
                [[ $exit_code -eq 0 ]] && _update_brewfile
                ;;
        esac
        return $exit_code
    }
fi

# --------------------------------------------
# precmd: プロンプト前に空行（初回除く）
# --------------------------------------------
precmd() {
  vcs_info
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

