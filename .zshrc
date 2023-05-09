alias ls="ls -Gwltr"
alias new='vim $(uuidgen).md && echo "Created: "$_'
alias venv='python3 -m venv venv && source ./venv/bin/activate && pip install --upgrade pip'
alias vimrc='vim $HOME/.vimrc'
alias webui='cd $HOME/stable-diffusion-webui && bash webui.sh && cd $HOME'
alias yta='yt-dlp --extract-audio --audio-format m4a -o "%(title)s.%(ext)s"'
alias ytv='yt-dlp -o "%(title).200s.%(ext)s"'
alias zshrc='vim $HOME/.zshrc'
alias update='brew update && brew upgrade && brew list --cask | xargs brew upgrade --cask && brew cleanup'
autoload -Uz compinit && compinit
bindkey jj vi-cmd-mode
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(starship init zsh)"
export HISTSIZE=10000
export LANG=en_US.UTF-8
export LSCOLORS=exfxcxdxbxegedabagacad
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
export PATH=$PATH:~/.local/bin
setopt auto_cd
setopt complete_in_word
setopt correct
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt list_packed
setopt share_history
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:default' menu select=1
zstyle ':completion::complete:*' use-cache true

autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^N" history-beginning-search-forward-end
bindkey "^P" history-beginning-search-backward-end
