# ============================================
# common.sh - シェル共通設定
# ============================================

# --------------------------------------------
# パッケージマネージャー初期化
# --------------------------------------------
# Homebrew (macOS)
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Linuxbrew
if [ -d /home/linuxbrew/.linuxbrew/bin ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Nix
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# --------------------------------------------
# 環境変数
# --------------------------------------------
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$HOME/.local/bin:$HOME/.lmstudio/bin:$HOME/.antigravity/antigravity/bin:$PATH"

export LANG=en_US.UTF-8
export HISTSIZE=10000
export SAVEHIST=10000

# MANPAGER: nvim があれば使う、なければ vim
if command -v nvim &> /dev/null; then
    export MANPAGER="nvim +Man!"
else
    export MANPAGER="col -b -x|vim -R -c 'set ft=man nolist nomod noma' -"
fi

# --------------------------------------------
# エイリアス
# --------------------------------------------
if command -v eza &> /dev/null; then
    alias ls='eza --group-directories-first'
    alias tree='eza --tree'
else
    # macOS は -G、Linux は --color=auto
    if [ "$(uname)" = "Darwin" ]; then
        alias ls='ls -G'
    else
        alias ls='ls --color=auto'
    fi
fi

alias grep='grep --color=auto'

# nvim があれば vim エイリアスを設定
if command -v nvim &> /dev/null; then
    alias vim='nvim'
    alias vi='nvim'
fi

note() {
  ${EDITOR:-vim} /tmp/note.md -c "setlocal buftype=nofile bufhidden=wipe noswapfile"
}
alias dl='yt-dlp -o "%(title)s.%(ext)s"'

# --------------------------------------------
# プロンプト (starship 風)
# --------------------------------------------
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats ' %F{yellow}%b%f'
zstyle ':vcs_info:*' enable git
setopt prompt_subst

PROMPT='%F{blue}%1~%f${vcs_info_msg_0_}
❯ '
