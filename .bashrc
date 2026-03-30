# ============================================
# .bashrc
# ============================================

# 対話シェルチェック
case $- in
    *i*) ;;
      *) return;;
esac

if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [ -d /home/linuxbrew/.linuxbrew/bin ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

export PATH="$HOME/.local/bin:$HOME/.lmstudio/bin:$HOME/.antigravity/antigravity/bin:$PATH"
export LANG=en_US.UTF-8
export HISTSIZE=10000
export SAVEHIST=10000
HISTCONTROL=ignoreboth:erasedups
HISTFILESIZE=10000

if command -v nvim &> /dev/null; then
    export MANPAGER="nvim +Man!"
else
    export MANPAGER="col -b -x|vim -R -c 'set ft=man nolist nomod noma' -"
fi

_dotfiles_root() {
    local repo_path="github.com/schroneko/dotfiles"

    if command -v ghq &>/dev/null; then
        printf '%s/%s\n' "$(ghq root)" "${repo_path}"
    else
        printf '%s/%s\n' "$HOME/ghq" "${repo_path}"
    fi
}

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
    export EDITOR=nvim
    alias vim='nvim'
    alias vi='nvim'
fi

note() {
  ${EDITOR:-vim} /tmp/note.md -c "setlocal buftype=nofile bufhidden=wipe noswapfile"
}
alias dl='yt-dlp -o "%(title)s.%(ext)s"'

dotfiles_sync_now() {
    "$(_dotfiles_root)/scripts/dotfiles-sync.sh" "$@"
}
alias sync-now='dotfiles_sync_now'

if command -v brew &> /dev/null; then
    _dotfiles_refresh_brewfiles() {
        local root="$(_dotfiles_root)"
        local manager="$root/scripts/brewfile-manager.sh"

        [[ -x "$manager" ]] || return 0
        BREWFILE_SYNC_DISABLE=1 "$manager" track -- "$@" >/dev/null || \
            echo "Warning: Brewfile update failed" >&2
    }

    brew() {
        command brew "$@"
        local exit_code=$?

        case "$1" in
            install|uninstall|remove|reinstall|tap|untap)
                if [[ $exit_code -eq 0 && -z "${BREWFILE_SYNC_DISABLE:-}" ]]; then
                    _dotfiles_refresh_brewfiles "$@"
                fi
                ;;
        esac

        return $exit_code
    }
fi

shopt -s histappend
shopt -s checkwinsize
shopt -s cdspell

if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

bind "set completion-ignore-case on"

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

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
