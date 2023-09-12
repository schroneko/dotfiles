# Load Fig pre block
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"

# Aliases
alias ls="ls -Gwltr"
alias update='brew update && brew upgrade && brew cleanup'
alias venv='python3 -m venv venv && source venv/bin/activate && pip install --upgrade pip'
alias webui='cd $HOME/stable-diffusion-webui && bash webui.sh && cd $HOME'
alias note='vim $HOME/Downloads/prettier/text.md'

# Initialization
autoload -Uz compinit && compinit

# Key bindings
bindkey jj vi-cmd-mode

# Environment variables
export HISTSIZE=10000
export LANG=en_US.UTF-8
export LSCOLORS=exfxcxdxbxegedabagacad
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
export PATH=$PATH:~/.local/bin

# Eval statements
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(starship init zsh)"
eval "$(sheldon source)"

# Set options
setopt auto_cd complete_in_word correct hist_ignore_all_dups hist_ignore_dups hist_reduce_blanks hist_save_no_dups list_packed share_history

# Completion styles
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:default' menu select=1
zstyle ':completion::complete:*' use-cache true

# Load Fig post block
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
