eval "$(/opt/homebrew/bin/brew shellenv)"
# [[ -z "$TMUX" && "$TERM" != "screen" && "$TERM" != "tmux" ]] && tmux && exit

source ${ZSH_CUSTOM:-~/.zsh}/plugins/zsh-system-clipboard/zsh-system-clipboard.zsh

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Alias
alias ls="ls -Gwltr"
alias new='vim $(uuidgen).md && echo "Created: "$_'
alias yta='yt-dlp --extract-audio --audio-format m4a -o "%(title)s.%(ext)s"'
alias ytv='yt-dlp -o "%(title).200s.%(ext)s"'
alias today='vim $(date -I).md'
alias vimrc='vim $HOME/.vimrc'
alias zshrc='vim $HOME/.zshrc'
alias arc='vim $HOME/.alacritty.yml'
alias tmuxrc='vim $HOME/.tmux.conf'
alias rip='vim +Rg'
alias webui='cd $HOME/stable-diffusion-webui && bash webui.sh'
alias venv='python3 -m venv venv && source ./venv/bin/activate && pip install --upgrade pip'

# Keybind
## When you type jj, change to vi-mode on zsh
bindkey jj vi-cmd-mode

autoload -Uz compinit && compinit

# Env
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

# Style
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:default' menu select=1
zstyle ':completion::complete:*' use-cache true

# Fuzzy Finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export MANPAGER="col -bx | vim -c 'set ft=man nolist' -MR -"
setopt interactivecomments
source /opt/homebrew/opt/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
