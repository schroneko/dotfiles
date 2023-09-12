# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
alias ls="ls -Gwltr"
alias new='vim $(uuidgen).md && echo "Created: "$_'
alias update='brew update && brew upgrade && brew cleanup'
alias venv='python3 -m venv venv && source venv/bin/activate && pip install --upgrade pip'
alias vimrc='vim $HOME/.vimrc'
alias webui='cd $HOME/stable-diffusion-webui && bash webui.sh && cd $HOME'
alias icloud='cd /Users/schroneko/Library/Mobile\ Documents/com\~apple\~CloudDocs'
alias yta='yt-dlp --extract-audio --audio-format m4a'
alias ytv='yt-dlp'
alias zshrc='vim $HOME/.zshrc'
alias note='vim $HOME/Downloads/prettier/text.md'
autoload -Uz compinit && compinit
bindkey jj vi-cmd-mode
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(starship init zsh)"
eval "$(sheldon source)"
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

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
