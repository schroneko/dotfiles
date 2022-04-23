autoload -Uz colors   && colors
autoload -Uz compinit && compinit

setopt auto_cd
setopt complete_in_word
setopt correct
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt list_packed
setopt share_history

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:default' menu select=1
zstyle ':completion::complete:*' use-cache true

export LANG=en_US.UTF-8
export LSCOLORS=exfxcxdxbxegedabagacad
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
export PATH="$VOLTA_HOME/bin:$PATH"
export PATH=~/.deno/bin:$PATH
export VOLTA_HOME="$HOME/.volta"

alias bu='brew update && brew upgrade && brew upgrade --cask && brew cleanup'
alias dia='vim ~/diary/$(date "+%Y/%m/%d.md")'
alias ds='find . -name '.DS_Store' -or -name '.localized' -type f -ls -delete'
alias gall='git add . && git commit -m "update" && git push origin main'
alias la="ls -G -w -a"
alias ls="ls -G -w"
alias rm="rm -i"
alias zshrc="vim ~/.zshrc && source ~/.zshrc"
alias vimrc="vim ~/.vimrc"

alias add="git add"
alias commit="git commit"
alias push="git push"

eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(starship init zsh)"

chpwd() { ls }

autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end
