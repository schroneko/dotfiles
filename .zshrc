# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && . "$HOME/.fig/shell/zshrc.pre.zsh"
autoload -Uz colors && colors
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

HISTFILE=~/.zsh_history HISTSIZE=100000
SAVEHIST=100000

zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:default' menu select=1
zstyle ':completion::complete:*' use-cache true

export LANG=en_US.UTF-8
export LSCOLORS=exfxcxdxbxegedabagacad
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

alias ds='find $HOME -name ".DS_Store" -type f -ls -delete -or -name ".localized" -type f -ls -delete 2> /dev/null'
alias gall='git add . && git commit -m "update" && git push origin main'
alias la="ls -G -w -a"
alias ls="ls -G -w"

alias add="git add"
alias commit="git commit"
alias push="git push"
alias mkdir='{ IFS= read -r d && mkdir -p "$d" && cd "$_"; } <<<'

if type trash >/dev/null 2>&1; then
    alias rm='trash -F'
fi

alias update='brew update && brew upgrade && brew upgrade --cask --greedy && mas upgrade'

alias list='todoist list'
alias add='todoist add'
alias del='todoist delete'

eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(starship init zsh)"

export PATH="/opt/homebrew/opt/node@16/bin:$PATH"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

export PATH="/Applications/Xcode.app/Contents/Developer/usr/bin//bin:$PATH"
export FIG_WORKFLOWS_KEYBIND='\ew'

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && . "$HOME/.fig/shell/zshrc.post.zsh"
