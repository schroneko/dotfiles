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
# プロンプト
# --------------------------------------------
setopt prompt_subst

_git_prompt_info() {
    git rev-parse --git-dir >/dev/null 2>&1 || return

    local branch=$(git branch --show-current 2>/dev/null || echo "detached")
    local status_output=$(git --no-optional-locks status --porcelain 2>/dev/null)

    local modified=$(echo "$status_output" | grep -c "^ M" || true)
    local added=$(echo "$status_output" | grep -c "^A" || true)
    local deleted=$(echo "$status_output" | grep -c "^D" || true)
    local untracked=$(echo "$status_output" | grep -c "^??" || true)

    local ahead_behind=$(git --no-optional-locks rev-list --left-right --count HEAD...@{upstream} 2>/dev/null || echo "0 0")
    local ahead=$(echo "$ahead_behind" | awk '{print $1}')
    local behind=$(echo "$ahead_behind" | awk '{print $2}')

    local git_status=""
    [[ $modified -gt 0 ]] && git_status="${git_status}~${modified}"
    [[ $added -gt 0 ]] && git_status="${git_status}+${added}"
    [[ $deleted -gt 0 ]] && git_status="${git_status}x${deleted}"
    [[ $untracked -gt 0 ]] && git_status="${git_status}?${untracked}"
    [[ $ahead -gt 0 ]] && git_status="${git_status}>${ahead}"
    [[ $behind -gt 0 ]] && git_status="${git_status}<${behind}"

    if [[ -n "$git_status" ]]; then
        printf " %%F{green}git%%f %%F{yellow}%s%%f %%F{red}[%s]%%f" "$branch" "$git_status"
    else
        printf " %%F{green}git%%f %%F{yellow}%s%%f" "$branch"
    fi
}

PROMPT='%F{cyan}%~%f$(_git_prompt_info)
❯ '
