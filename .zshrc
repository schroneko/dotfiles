eval "$(/opt/homebrew/bin/brew shellenv)"

setopt auto_cd
setopt complete_in_word
setopt correct
setopt list_packed
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_reduce_blanks
setopt hist_save_no_dups

autoload -Uz compinit && compinit
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:default' menu select=1
zstyle ':completion::complete:*' use-cache true

export LANG=en_US.UTF-8
export LSCOLORS=exfxcxdxbxegedabagacad
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

alias update="brew update && brew upgrade && brew upgrade --cask --greedy && brew cleanup && mas upgrade"

