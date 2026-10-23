# ============================================
# .zshrc
# ============================================

# --------------------------------------------
# 環境変数
# --------------------------------------------
export HISTSIZE=10000
export SAVEHIST=10000
export PATH="$HOME/.local/bin:$PATH"

if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

if command -v nvim &> /dev/null; then
    export MANPAGER="nvim +Man!"
else
    export MANPAGER="col -b -x|vim -R -c 'set ft=man nolist nomod noma' -"
fi

_dotagents_repo="${GHQ_ROOT:-$HOME/ghq}/github.com/schroneko/dotagents"
if [[ -d "${_dotagents_repo}/.git" ]] && ! git -C "${_dotagents_repo}" config --get filter.claude-model.clean &>/dev/null; then
    git -C "${_dotagents_repo}" config filter.claude-model.clean "jq 'del(.model)'" 2>/dev/null
    git -C "${_dotagents_repo}" config filter.codex-threads.clean "awk -f scripts/strip-codex-thread-projects.awk" 2>/dev/null
fi
unset _dotagents_repo

# --------------------------------------------
# Zsh オプション
# --------------------------------------------
setopt prompt_subst
setopt auto_cd
setopt hist_ignore_dups
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt share_history
setopt complete_in_word

autoload -U +X compinit && compinit
bindkey -e
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select


if command -v eza &> /dev/null; then
    alias ls='eza --group-directories-first'
    alias tree='eza --tree'
else
    if [ "$(uname)" = "Darwin" ]; then
        alias ls='ls -G'
    else
        alias ls='ls --color=auto'
    fi
fi

alias grep='grep --color=auto'

if command -v nvim &> /dev/null; then
    alias vim='nvim'
    alias vi='nvim'
fi

note() {
  ${EDITOR:-vim} -c "setlocal buftype=nofile bufhidden=wipe noswapfile filetype=markdown"
}
alias dl='yt-dlp -o "%(title)s.%(ext)s"'

claude() {
    if [[ "$PWD" == "$HOME" ]]; then
        local scratch="$HOME/Documents/ClaudeCode/$(date +%Y-%m-%d)"
        mkdir -p "$scratch" || return 1
        (cd "$scratch" && command claude "$@")
    else
        command claude "$@"
    fi
}


if command -v mise &> /dev/null; then
    eval "$(mise activate zsh)"
elif [ -x "$HOME/.local/bin/mise" ]; then
    eval "$("$HOME/.local/bin/mise" activate zsh)"
fi

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

precmd() {
  if [ -z "$_FIRST_PROMPT" ]; then
    _FIRST_PROMPT=1
  else
    echo
  fi
}

if [ -n "$HOMEBREW_PREFIX" ]; then
    [ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
        source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    [ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
        source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

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

export PATH="/Users/username/.antigravity/antigravity/bin:$PATH"

export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C

export PATH="$HOME/.local/bin:$PATH"

export PATH="/Users/username/.kimi-code/bin:$PATH"
