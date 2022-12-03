alias ls="ls -G -w"
alias yta='yt-dlp --extract-audio --audio-format m4a -o "%(title)s.%(ext)s"'
alias ytv='yt-dlp -o "%(title)s.%(ext)s"'
autoload -Uz compinit && compinit
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(starship init zsh)"
export HISTSIZE=10000
export LANG=en_US.UTF-8
export LSCOLORS=exfxcxdxbxegedabagacad
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
export PATH="/opt/homebrew/opt/node@16/bin:$PATH"
setopt auto_cd
setopt complete_in_word
setopt correct
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt list_packed
setopt share_history
touch() { mkdir -p $( dirname "$1") && /usr/bin/touch "$1" }
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:default' menu select=1
zstyle ':completion::complete:*' use-cache true
