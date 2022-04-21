export LANG=en_US.UTF-8
autoload -Uz compinit
compinit

setopt auto_cd
setopt correct
setopt complete_in_word
setopt list_packed
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:default' menu select=1
zstyle ':completion::complete:*' use-cache true

export LSCOLORS=exfxcxdxbxegedabagacad
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

export PATH=~/.deno/bin:$PATH
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

alias bu='brew update && brew upgrade && brew upgrade --cask && brew cleanup'
alias dia='vim ~/diary/$(date "+%Y/%m/%d.md")'
alias diaopen='open -a "/Applications/Google Chrome.app/" ~/diary/$(date "+%Y/%m/%d.md")'
alias ds='find $HOME –name ‘.DS_Store’ –type f –delete'
alias gall='git add . && git commit -m "update" && git push origin main'
alias ls="ls -G -w"
alias la="ls -G -w -a"

eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(starship init zsh)"

chpwd() { ls }

